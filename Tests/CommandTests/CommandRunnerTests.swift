import Mockable
import Testing
@testable import Command

#if !os(Linux)
    struct CommandRunnerTests {
        @Test func runs_successfully() async throws {
            // Given
            let commandRunner = CommandRunner()

            // When
            #if os(Windows)
                let result = try await commandRunner.run(arguments: ["cmd.exe", "/c", "echo", "foo"])
                    .reduce(into: [String]()) { $0.append($1.string()) }
                // Then
                #expect(result == ["foo\r\n"])
            #else
                let result = try await commandRunner.run(arguments: ["echo", "foo"])
                    .reduce(into: [String]()) { $0.append($1.string()) }
                // Then
                #expect(result == ["foo\n"])
            #endif
        }

        @Test func discardOutput_emitsNoEventsButStillRuns() async throws {
            #if !os(Windows)
                let commandRunner = CommandRunner()

                // Capturing yields the command's output...
                let captured = try await commandRunner.run(arguments: ["echo", "foo"], output: .capture)
                    .reduce(into: [String]()) { $0.append($1.string() ?? "") }
                #expect(captured == ["foo\n"])

                // ...while discarding allocates no pipes and emits nothing, yet still runs.
                let discardedEventCount = try await commandRunner.run(arguments: ["echo", "foo"], output: .discard)
                    .reduce(into: 0) { count, _ in count += 1 }
                #expect(discardedEventCount == 0)
            #endif
        }

        @Test func discardOutput_stillReportsNonZeroExit() async throws {
            #if !os(Windows)
                let commandRunner = CommandRunner()

                await #expect(throws: CommandError.self) {
                    for try await _ in commandRunner.run(arguments: ["/bin/sh", "-c", "exit 7"], output: .discard) {}
                }
            #endif
        }

        @Test func lookupExecutable_withAbsolutePath() throws {
            // Given
            let commandRunner = CommandRunner()
            #if os(Windows)
                let absolutePath = "C:/Windows/System32/cmd.exe"
            #else
                let absolutePath = "/bin/echo"
            #endif

            // When
            let executableURL = try commandRunner.lookupExecutable(firstArgument: absolutePath)

            // Then
            #expect(executableURL.path == absolutePath)
        }

        @Test func lookupExecutable_withRegularCommand() throws {
            // Given
            let commandRunner = CommandRunner()
            #if os(Windows)
                let command = "cmd.exe"
            #else
                let command = "echo"
            #endif

            // When
            let executableURL = try commandRunner.lookupExecutable(firstArgument: command)

            // Then
            #expect(executableURL.path.hasSuffix("/\(command)") == true)
        }

        @Test func lookupExecutable_withInvalidCommand() throws {
            // Given
            let commandRunner = CommandRunner()
            let command = "nonexistentcommand"

            // When & Then
            #expect(throws: (any Error).self, performing: { try commandRunner.lookupExecutable(firstArgument: command) })
        }

        @Test func lookupExecutable_withMissingExecutableCommand() throws {
            // Given
            let commandRunner = CommandRunner()

            // When & Then
            #expect(throws: (any Error).self, performing: { try commandRunner.lookupExecutable(firstArgument: nil) })
        }

        @Test func commandError_terminated_descriptionIncludesStderr() {
            // Given
            let error = CommandError.terminated(
                70,
                stderr: "xcodebuild: error: No such scheme.",
                command: ["xcodebuild", "test-without-building", "-enumerate-tests"]
            )

            // When
            let description = error.description

            // Then
            #expect(
                description ==
                    "The command 'xcodebuild test-without-building -enumerate-tests' terminated with the code 70:\nxcodebuild: error: No such scheme."
            )
        }

        @Test func commandError_terminated_descriptionOmitsEmptyStderr() {
            // Given
            let error = CommandError.terminated(
                1,
                stderr: "   \n",
                command: ["echo", "hi"]
            )

            // When
            let description = error.description

            // Then
            #expect(description == "The command 'echo hi' terminated with the code 1")
        }

        @Test func commandError_localizedDescriptionMatchesDescription() {
            // Given
            let error = CommandError.terminated(
                2,
                stderr: "boom",
                command: ["ls", "/missing"]
            )

            // When
            let localized = (error as any Error).localizedDescription

            // Then
            #expect(localized == "The command 'ls /missing' terminated with the code 2:\nboom")
        }

        @Test func commandError_invalidWorkingDirectory_empty_descriptionMentionsGetcwd() {
            // Given
            let error = CommandError.invalidWorkingDirectory("")

            // When
            let description = error.description

            // Then
            #expect(
                description ==
                    "Couldn't resolve the current working directory: FileManager returned an empty path (getcwd likely failed)."
            )
        }

        @Test func commandError_invalidWorkingDirectory_nonEmpty_includesPath() {
            // Given
            let error = CommandError.invalidWorkingDirectory("relative/path")

            // When
            let description = error.description

            // Then
            #expect(description == "The resolved working directory 'relative/path' is not a valid absolute path.")
        }
    }
#endif
