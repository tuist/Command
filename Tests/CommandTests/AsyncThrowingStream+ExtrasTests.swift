import Command
import Foundation
import Testing

struct AsyncThrowingStreamExtrasTests {
    let subject = CommandRunner()

    @Test func concatenatedString_returnsTheConcatenatedString() async throws {
        // When
        #if os(Windows)
            let result = try await subject
                .run(arguments: ["cmd.exe", "/c", "echo", "foo"])
                .concatenatedString().trimmingCharacters(in: .whitespacesAndNewlines)
        #else
            let result = try await subject
                .run(arguments: ["echo", "foo"])
                .concatenatedString().trimmingCharacters(in: .whitespacesAndNewlines)
        #endif

        // Then
        #expect(result == "foo")
    }

    @Test func awaiting_of_piped_stream() async throws {
        // When
        #if os(Windows)
            try await subject
                .run(arguments: ["cmd.exe", "/c", "echo", "foo"])
                .pipedStream()
                .awaitCompletion()
        #else
            try await subject
                .run(arguments: ["echo", "foo"])
                .pipedStream()
                .awaitCompletion()
        #endif
    }
}
