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
    }
#endif
