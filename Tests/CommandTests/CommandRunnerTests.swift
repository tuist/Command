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
    }
#endif
