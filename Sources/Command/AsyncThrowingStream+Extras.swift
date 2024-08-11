import Foundation

extension AsyncThrowingStream where Element == CommandEvent {
    /// It concatenates the stdout and stderr events encoded as strings using the provided encoding.
    /// - Parameter encoding: The encoding to use. When absent, it defaults to UTF-8.
    /// - Returns: The result of concatenating all the strings.
    public func concatenatedString(
        including: Set<CommandEvent.Pipeline> = Set([.standardError, .standardOutput]),
        encoding: String.Encoding = .utf8
    ) async throws -> String {
        try await reduce(into: "") { acc, event in
            if including.contains(event.pipeline) {
                acc.append(event.string(encoding: encoding) ?? "")
            }
        }
    }
}
