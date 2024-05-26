import Foundation
@preconcurrency import Logging
import Path
import TSCBasic

/**
 `CommandRunning` is a protocol that declares the interface to run system processes.
 The main implementation of the protocol is `CommandRunner`.
 */
public protocol CommandRunning: Sendable {
    /// Runs a command in the system.
    /// - Parameters:
    ///   - arguments: The command arguments where the first argument represents the executable. If the executable is not an
    /// absolute path, the executable will be looked up in the system and the execution will fail if the executable can't be
    /// found.
    ///   - environment: The environment variables that will be passed to the process running the command.
    ///   - workingDirectory: The directory from where the command will be executed.
    ///   - startNewProcessGroup: If true, a new progress group is created for the child making it continue running even if the
    /// parent is killed or interrupted.
    ///   - log: If true, the standard output and error messages will be logged through the logger's `.debug` and `.error`
    /// interfaces respectively.
    /// - Returns: An async throwing stream to subscribe to the emitted events and completion of the underlying process.
    func run(
        arguments: [String],
        environment: [String: String],
        workingDirectory: Path.AbsolutePath?,
        startNewProcessGroup: Bool,
        log: Bool
    ) -> AsyncThrowingStream<CommandEvent, any Error>
}

extension CommandRunning {
    /// Runs a command given its aguments.
    /// The command will inherit the environment variables and working directory from the current process and the process
    /// lifecycle will be bound to the current process'.
    ///   - arguments: The command arguments where the first argument represents the executable. If the executable is not an
    /// absolute path, the executable will be looked up in the system and the execution will fail if the executable can't be
    /// found.
    /// - Returns: An async throwing stream to subscribe to the emitted events and completion of the underlying process.
    public func run(arguments: [String]) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: ProcessEnv.vars,
            workingDirectory: nil,
            startNewProcessGroup: false,
            log: true
        )
    }

    /// Runs a command given its aguments.
    /// The command will inherit the environment variables and working directory from the current process and the process
    /// lifecycle will be bound to the current process'.
    /// - Parameters:
    ///   - arguments: The command arguments where the first argument represents the executable. If the executable is not an
    /// absolute path, the executable will be looked up in the system and the execution will fail if the executable can't be
    /// found.
    ///   - log: If true, the standard output and error messages will be logged through the logger's `.debug` and `.error`
    /// interfaces respectively.
    /// - Returns: An async throwing stream to subscribe to the emitted events and completion of the underlying process.
    public func run(arguments: [String], log: Bool) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: ProcessEnv.vars,
            workingDirectory: nil,
            startNewProcessGroup: false,
            log: log
        )
    }

    public func run(
        arguments: [String],
        environment: [String: String]
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: environment,
            log: true
        )
    }

    public func run(
        arguments: [String],
        environment: [String: String],
        log: Bool
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: environment,
            workingDirectory: nil,
            startNewProcessGroup: false,
            log: log
        )
    }

    public func run(
        arguments: [String],
        workingDirectory: Path.AbsolutePath
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            workingDirectory: workingDirectory,
            log: true
        )
    }

    public func run(
        arguments: [String],
        workingDirectory: Path.AbsolutePath,
        log: Bool
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: ProcessEnv.vars,
            workingDirectory: workingDirectory,
            startNewProcessGroup: false,
            log: log
        )
    }
}

public enum CommandEvent: Sendable {
    case standardOutput([UInt8])
    case standardError([UInt8])

    public var utf8String: String {
        switch self {
        case let .standardOutput(bytes):
            String(decoding: bytes, as: Unicode.UTF8.self)
        case let .standardError(bytes):
            String(decoding: bytes, as: Unicode.UTF8.self)
        }
    }
}

public enum CommandError: Error, CustomStringConvertible, Sendable {
    case couldntGetWorkingDirectory
    case terminated(Int32, stderr: String)
    case signalled(Int32)

    public var description: String {
        switch self {
        case .couldntGetWorkingDirectory: return "Couldn't obtain the working directory necessary to run the command"
        case let .signalled(code): return "The command terminated after receiving a signal with code \(code)"
        case let .terminated(code, _): return "The command terminated with the code \(code)"
        }
    }
}

public struct CommandRunner: Sendable {
    let logger: Logger?

    public init(logger: Logger? = nil) {
        self.logger = logger
    }

    public func run(
        arguments: [String],
        environment: [String: String] = ProcessEnv.vars,
        workingDirectory: Path.AbsolutePath? = nil,
        startNewProcessGroup: Bool = false,
        log _: Bool = false
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        AsyncThrowingStream(CommandEvent.self, bufferingPolicy: .unbounded) { continuation in
            DispatchQueue(label: "io.tuist.command", attributes: .concurrent).async {
                do {
                    // Get the working directory if not passed.
                    var workingDirectory = workingDirectory
                    if workingDirectory == nil {
                        guard let currentWorkingDirectory = localFileSystem.currentWorkingDirectory else {
                            throw CommandError.couldntGetWorkingDirectory
                        }
                        // swiftlint:disable:next force_try
                        workingDirectory = try! .init(validating: currentWorkingDirectory.pathString)
                    }

                    var collectedStdErr = ""

                    // Process
                    let process = TSCBasic.Process(
                        arguments: arguments,
                        environment: environment,
                        // swiftlint:disable:next force_try
                        workingDirectory: try! TSCBasic
                            .AbsolutePath(validating: workingDirectory!.pathString),
                        outputRedirection: .stream(stdout: { output in
                            let outputString = String(decoding: output, as: Unicode.UTF8.self)
                            continuation.yield(.standardOutput(output))
                            if let logger {
                                logger.debug("\(outputString)", source: "command: \(arguments.joined(separator: " "))")
                            }
                        }, stderr: { output in
                            let outputString = String(decoding: output, as: Unicode.UTF8.self)
                            collectedStdErr.append(outputString)
                            continuation.yield(.standardError(output))
                            if let logger {
                                logger.error("\(outputString)", source: "command: \(arguments.joined(separator: " "))")
                            }
                        }, redirectStderr: false),
                        startNewProcessGroup: startNewProcessGroup,
                        loggingHandler: nil
                    )

                    continuation.onTermination = { termination in
                        switch termination {
                        case .cancelled:
                            process.signal(SIGINT)
                        default:
                            break
                        }
                    }

                    try process.launch()
                    let result = try process.waitUntilExit()

                    switch result.exitStatus {
                    case let .signalled(signal: code):
                        if code != 0 {
                            throw CommandError.signalled(code)
                        }
                    case let .terminated(code: code):
                        if code != 0 {
                            throw CommandError.terminated(code, stderr: collectedStdErr)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
