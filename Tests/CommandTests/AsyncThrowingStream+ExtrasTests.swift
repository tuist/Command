import Command
import Foundation
import Testing

struct AsyncThrowingStreamExtrasTests {
    let subject = CommandRunner()

    @Test func concatenatedString_returnsTheConcatenatedString() async throws {
        // When
        let result = try await subject
            .run(arguments: ["echo", "foo"])
            .concatenatedString().trimmingCharacters(in: .whitespacesAndNewlines)

        // Then
        #expect(result == "foo")
    }

    @Test func awaiting_of_piped_stream() async throws {
        // When
        try await subject
            .run(arguments: ["echo", "foo"])
            .pipedStream()
            .awaitCompletion()
    }
}
