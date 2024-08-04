import Testing
@testable import Command

@Test func test_runs_successfully() async throws {
    // Given
    let commandRunner = CommandRunner()

    // When
    let result = try await commandRunner.run(arguments: ["echo", "foo"]).reduce(into: [String]()) { $0.append($1.utf8String) }

    // Then
    #expect(result == ["foo\n"])
}
