import Foundation
import Logging
// Mockable depends on Combine, which is only available on macOS.
#if os(macOS)
import Mockable
#endif
import Path

/**
 `CommandRunning` is a protocol that declares the interface to run system processes.
 The main implementation of the protocol is `CommandRunner`.
 */
#if os(macOS)
@Mockable
#endif
public protocol CommandRunning: Sendable {
    /// Runs a command in the system.
    /// - Parameters:
    ///   - arguments: The command arguments where the first argument represents the executable. If the executable is not an
    /// absolute path, the executable will be looked up in the system and the execution will fail if the executable can't be
    /// found.
    ///   - environment: The environment variables that will be passed to the process running the command.
    ///   - workingDirectory: The directory from where the command will be executed.
    /// - Returns: An async throwing stream to subscribe to the emitted events and completion of the underlying process.
    func run(
        arguments: [String],
        environment: [String: String],
        workingDirectory: Path.AbsolutePath?
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
            workingDirectory: nil
        )
    }

    public func run(
        arguments: [String],
        environment: [String: String]
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: environment,
            workingDirectory: nil
        )
    }

    public func run(
        arguments: [String],
        workingDirectory: Path.AbsolutePath
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: ProcessInfo.processInfo.environment,
            workingDirectory: workingDirectory
        )
    }
}

public enum CommandEvent: Sendable {
    public enum Pipeline: Hashable, Equatable {
        case standardOutput
        case standardError
    }

    case standardOutput([UInt8])
    case standardError([UInt8])

    /// Returns the event pipeline
    public var pipeline: Pipeline {
        switch self {
        case .standardOutput: .standardOutput
        case .standardError: .standardError
        }
    }

    /// Returns the event as a string encoded using the provided encoding.
    /// - Parameter encoding: Encoding to use.
    /// - Returns: The string version of the event.
    public func string(encoding: String.Encoding = .utf8) -> String? {
        switch self {
        case let .standardOutput(bytes),
             let .standardError(bytes):
            String(data: Data(bytes), encoding: encoding)
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
    case executableNotFound(String)
    case missingExecutableName

    public var description: String {
        switch self {
        case let .signalled(code): return "The command terminated after receiving a signal with code \(code)"
        case let .terminated(code, _): return "The command terminated with the code \(code)"
        case let .executableNotFound(name): return "Couldn't locate the executable '\(name)' in the environment."
        case .missingExecutableName: return "The executable name is missing."
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
        workingDirectory: Path.AbsolutePath? = nil
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
                    process.environment = environment

                    let processArguments = Array(arguments.dropFirst())
                    process.arguments = processArguments

                    let executable = try lookupExecutable(firstArgument: arguments.first)
                    process.executableURL = executable

                    logger?.debug("Running command: \(executable.absoluteString) \(processArguments.joined(separator: " "))")

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

    func lookupExecutable(firstArgument: String?) throws -> URL {
        guard let firstArgument else {
            throw CommandError.missingExecutableName
        }

        // If the first argument is an absolute URL to an executable, return it.
        if let executablePath = try? Path.AbsolutePath(validating: firstArgument) {
            return URL(fileURLWithPath: executablePath.pathString)
        }

        let command: String
        let arguments: [String]

        #if os(Windows)
            command = "C:\\Windows\\System32\\where.exe"
            arguments = [firstArgument]
        #else
            command = "/usr/bin/which"
            arguments = [firstArgument]
        #endif

        logger?.log(
            level: .debug,
            "Looking up executable \(firstArgument) by running: \(command) \(arguments.joined(separator: " "))"
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        process.environment = ProcessInfo.processInfo.environment
        process.currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = try pipe.fileHandleForReading.readToEnd()
        let output = String(data: data ?? .init(), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let output, !output.isEmpty else {
            throw CommandError.executableNotFound(firstArgument)
        }

        return URL(fileURLWithPath: output)
    }
}
