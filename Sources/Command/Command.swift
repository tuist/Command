import Foundation
import Logging
import Path

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
            environment: ProcessInfo.processInfo.environment,
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
            environment: ProcessInfo.processInfo.environment,
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
            environment: ProcessInfo.processInfo.environment,
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
        case let .standardOutput(bytes),
             let .standardError(bytes):
            String(decoding: bytes, as: Unicode.UTF8.self)
        }
    }

    public var isError: Bool {
        switch self {
        case .standardError: true
        case .standardOutput: false
        }
    }
}

public enum CommandError: Error, CustomStringConvertible, Sendable {
    case terminated(Int32, stderr: String)
    case signalled(Int32)
    case errorObtainingExecutable(executable: String, error: String)
    case executableNotFound(String)

    public var description: String {
        switch self {
        case let .signalled(code): return "The command terminated after receiving a signal with code \(code)"
        case let .terminated(code, _): return "The command terminated with the code \(code)"
        case let .errorObtainingExecutable(
            name,
            error
        ): return "There was an error trying to obtain the path to the executable '\(name)': \(error)"
        case let .executableNotFound(name): return "Couldn't locate the executable '\(name)' in the environment."
        }
    }
}

public struct CommandRunner: CommandRunning, Sendable {
    let logger: Logger?

    public init(logger: Logger? = nil) {
        self.logger = logger
    }

    public func run(
        arguments: [String],
        environment: [String: String] = ProcessInfo.processInfo.environment,
        workingDirectory: Path.AbsolutePath? = nil,
        startNewProcessGroup _: Bool = false,
        log _: Bool = false
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        AsyncThrowingStream(CommandEvent.self, bufferingPolicy: .unbounded) { continuation in
            DispatchQueue(label: "io.tuist.command", attributes: .concurrent).async {
                do {
                    // Get the working directory if not passed.
                    var workingDirectory = workingDirectory
                    if workingDirectory == nil {
                        // swiftlint:disable:next force_try
                        workingDirectory = try! .init(validating: FileManager.default.currentDirectoryPath)
                    }

                    let collectedStdErr: ThreadSafe<String> = ThreadSafe("")

                    // Process
                    let process = Process()
                    let stdoutPipe = Pipe()
                    let stderrPipe = Pipe()
                    let stdoutQueue = DispatchQueue(label: "io.tuist.Command.stdoutQueue")
                    let stderrQueue = DispatchQueue(label: "io.tuist.Command.stderrQueue")

                    stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                        let data = handle.availableData
                        if data.count > 0 {
                            stdoutQueue.async {
                                continuation.yield(.standardOutput([UInt8](data)))
                            }
                        }
                    }

                    stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                        let data = handle.availableData
                        if data.count > 0 {
                            stderrQueue.async {
                                continuation.yield(.standardError([UInt8](data)))
                                if let output = String(data: data, encoding: .utf8) {
                                    collectedStdErr.mutate { $0.append(output) }
                                }
                            }
                        }
                    }

                    process.currentDirectoryURL = URL(fileURLWithPath: workingDirectory!.pathString)
                    process.standardOutput = stdoutPipe
                    process.standardError = stderrPipe
                    process.arguments = Array(arguments.dropFirst())
                    process.environment = environment
                    process.executableURL = try lookupExecutable(firstArgument: arguments.first)

                    let threadSafeProcess = ThreadSafe(process)

                    continuation.onTermination = { termination in
                        switch termination {
                        case .cancelled:
                            if threadSafeProcess.value.isRunning {
                                threadSafeProcess.value.terminate()
                            }
                        default:
                            break
                        }
                    }

                    try process.run()
                    process.waitUntilExit()

                    // Read remaining data from stdout and stderr
                    stdoutQueue.sync {
                        if let data = try? stdoutPipe.fileHandleForReading.readToEnd(), data.count > 0 {
                            continuation.yield(.standardOutput([UInt8](data)))
                        }
                    }

                    stderrQueue.sync {
                        if let data = try? stderrPipe.fileHandleForReading.readToEnd(), data.count > 0 {
                            continuation.yield(.standardError([UInt8](data)))
                            if let output = String(data: data, encoding: .utf8) {
                                collectedStdErr.mutate { $0.append(output) }
                            }
                        }
                    }

                    stdoutPipe.fileHandleForReading.readabilityHandler = nil
                    stderrPipe.fileHandleForReading.readabilityHandler = nil

                    switch process.terminationReason {
                    case .exit:
                        if process.terminationStatus != 0 {
                            throw CommandError.terminated(process.terminationStatus, stderr: collectedStdErr.value)
                        }
                    case .uncaughtSignal:
                        if process.terminationStatus != 0 {
                            throw CommandError.signalled(process.terminationStatus)
                        }
                    @unknown default:
                        break
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    fileprivate func lookupExecutable(firstArgument: String?) throws -> URL? {
        guard let firstArgument else { return nil }

        // If the first argument is an absolute URL to an executable, return it.
        if let executablePath = try? Path.AbsolutePath(validating: firstArgument) {
            return URL(fileURLWithPath: executablePath.pathString)
        }

        let command: String
        let arguments: [String]

        #if os(Windows)
            command = "where"
            arguments = [firstArgument]
        #else
            command = "/usr/bin/which"
            arguments = [firstArgument]
        #endif

        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
        } catch {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            throw CommandError.errorObtainingExecutable(executable: firstArgument, error: output)
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        if let output = String(data: data, encoding: .utf8) {
            let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedOutput.isEmpty ? nil : URL(fileURLWithPath: trimmedOutput)
        }

        return nil
    }
}
