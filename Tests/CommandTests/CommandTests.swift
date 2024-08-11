import XCTest
@testable import Command

final class CommandTests: XCTestCase {
    func test_runs_successfully() async throws {
        // Given
        let commandRunner = CommandRunner()

        // When
        let result = try await commandRunner.run(arguments: ["echo", "foo"]).reduce(into: [String]()) { $0.append($1.string()) }

        // Then
        XCTAssertEqual(result, ["foo\n"])
    }

    func test_lookupExecutable_withAbsolutePath() throws {
        // Given
        let commandRunner = CommandRunner()
        let absolutePath = "/bin/echo"

        // When
        let executableURL = try commandRunner.lookupExecutable(firstArgument: absolutePath)

        // Then
        XCTAssertEqual(executableURL?.path, absolutePath)
    }

    func test_lookupExecutable_withRegularCommand() throws {
        // Given
        let commandRunner = CommandRunner()
        let command = "echo"

        // When
        let executableURL = try commandRunner.lookupExecutable(firstArgument: command)

        // Then
        XCTAssertNotNil(executableURL)
        XCTAssertTrue(executableURL!.path.hasSuffix("/\(command)"))
    }

    func test_lookupExecutable_withInvalidCommand() throws {
        // Given
        let commandRunner = CommandRunner()
        let command = "nonexistentcommand"

        // When
        let executableURL = try commandRunner.lookupExecutable(firstArgument: command)

        // Then
        XCTAssertNil(executableURL)
    }
}
