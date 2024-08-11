import Command
import Foundation
import XCTest

public final class AsyncThrowingStreamExtrasTests: XCTestCase {
    func test_concatenatedString_returnsTheConcatenatedString() async throws {
        // Given
        let commandRunner = CommandRunner()

        // When
        let result = try await commandRunner
            .run(arguments: ["echo", "foo"])
            .concatenatedString().trimmingCharacters(in: .whitespacesAndNewlines)

        // Then
        XCTAssertEqual(result, "foo")
    }
}
