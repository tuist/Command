import Foundation
import Path
/// An interface that exposes static functions to invoke system commands.
public enum Command {
    /// Runs a command given its aguments.
    /// The command will inherit the environment variables and working directory from the current process and the process
    /// lifecycle will be bound to the current process'.
    ///   - arguments: The command arguments where the first argument represents the executable. If the executable is not an
    /// absolute path, the executable will be looked up in the system and the execution will fail if the executable can't be
    /// found.
    /// - Returns: An async throwing stream to subscribe to the emitted events and completion of the underlying process.
    public static func run(arguments: [String]) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: ProcessInfo.processInfo.environment,
            workingDirectory: nil
        )
    }

    /// Runs a command in the system.
    /// - Parameters:
    ///   - arguments: The command arguments where the first argument represents the executable. If the executable is not an
    /// absolute path, the executable will be looked up in the system and the execution will fail if the executable can't be.
    ///   - environment: The environment variables that will be passed to the process running the command.
    /// - Returns: An async throwing stream to subscribe to the emitted events and completion of the underlying process.
    public static func run(
        arguments: [String],
        environment: [String: String]
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: environment,
            workingDirectory: nil
        )
    }

    /// Runs a command in the system.
    /// - Parameters:
    ///   - arguments: The command arguments where the first argument represents the executable. If the executable is not an
    /// absolute path, the executable will be looked up in the system and the execution will fail if the executable can't be.
    ///   - workingDirectory: The directory from where the command will be executed.
    /// - Returns: An async throwing stream to subscribe to the emitted events and completion of the underlying process.
    public static func run(
        arguments: [String],
        workingDirectory: Path.AbsolutePath
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        run(
            arguments: arguments,
            environment: ProcessInfo.processInfo.environment,
            workingDirectory: workingDirectory
        )
    }

    /// Runs a command in the system.
    /// - Parameters:
    ///   - arguments: The command arguments where the first argument represents the executable. If the executable is not an
    /// absolute path, the executable will be looked up in the system and the execution will fail if the executable can't be
    /// found.
    ///   - environment: The environment variables that will be passed to the process running the command.
    ///   - workingDirectory: The directory from where the command will be executed.
    /// - Returns: An async throwing stream to subscribe to the emitted events and completion of the underlying process.
    public static func run(
        arguments: [String],
        environment: [String: String],
        workingDirectory: Path.AbsolutePath?
    ) -> AsyncThrowingStream<CommandEvent, any Error> {
        CommandRunner().run(arguments: arguments, environment: environment, workingDirectory: workingDirectory)
    }
}
