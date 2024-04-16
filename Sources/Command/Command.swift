import Foundation
import Path
import TSCBasic

public protocol CommandRunning {
    func run(
        arguments: [String],
        environment: [String: String],
        workingDirectory: Path.AbsolutePath?,
        startNewProcessGroup: Bool
    ) -> AsyncThrowingStream<CommandEvent, any Error>
}

extension CommandRunning {
    public func run(arguments: [String]) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: ProcessEnv.vars,
            workingDirectory: nil,
            startNewProcessGroup: false
        )
    }

    public func run(
        arguments: [String],
        environment: [String: String]
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: environment,
            workingDirectory: nil,
            startNewProcessGroup: false
        )
    }

    public func run(
        arguments: [String],
        workingDirectory: Path.AbsolutePath
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: ProcessEnv.vars,
            workingDirectory: workingDirectory,
            startNewProcessGroup: false
        )
    }
}

public enum CommandEvent {
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

public enum CommandError: Error, CustomStringConvertible {
    case couldntGetWorkingDirectory
    case terminated(Int32)
    case signalled(Int32)

    public var description: String {
        switch self {
        case .couldntGetWorkingDirectory: return "Couldn't obtain the working directory necessary to run the command"
        case let .signalled(code): return "The command terminated after receiving a signal with code \(code)"
        case let .terminated(code): return "The command terminated with the code \(code)"
        }
    }
}

public struct CommandRunner {
    public init() {}

    public func run(
        arguments: [String],
        environment: [String: String] = ProcessEnv.vars,
        workingDirectory: Path.AbsolutePath? = nil,
        startNewProcessGroup: Bool = false
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
                        workingDirectory = try! .init(validating: currentWorkingDirectory.pathString)
                    }

                    // Process
                    let process = TSCBasic.Process(
                        arguments: arguments,
                        environment: environment,
                        workingDirectory: try! TSCBasic
                            .AbsolutePath(validating: workingDirectory!.pathString),
                        outputRedirection: .stream(stdout: { output in
                            continuation.yield(.standardOutput(output))
                        }, stderr: { output in
                            continuation.yield(.standardError(output))
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
                            throw CommandError.terminated(code)
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
