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
}
