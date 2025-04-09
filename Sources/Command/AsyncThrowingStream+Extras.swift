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

    /// Concatenates the stdout and stderr events encoded as strings using the provided encoding.
    /// - Parameter encoding: The encoding to use. When absent, it defaults to UTF-8.
    /// - Returns: The result of concatenating all the strings, and the error if one occurred.
    public func nonThrowingConcatenatedString(
      including: Set<CommandEvent.Pipeline> = [.standardOutput, .standardError],
      encoding: String.Encoding = .utf8
    ) async -> (output: String, error: Error?) {
      var output = ""

      do {
        for try await event in self {
          if including.contains(event.pipeline),
             let stringValue = event.string(encoding: encoding) {
            output.append(stringValue)
          }
        }
        return (output, nil)
      } catch {
        return (output, error)
      }
    }

    /// Returns a new AsyncThrowingStream that pipes the standard output and standard error through the process' standard output
    /// and error.
    public func pipedStream() -> AsyncThrowingStream<Element, Error> {
        AsyncThrowingStream<Element, Error> { continuation in
            Task {
                do {
                    for try await event in self {
                        switch event.pipeline {
                        case .standardOutput:
                            if let output = event.string(encoding: .utf8) {
                                FileHandle.standardOutput.write(Data(output.utf8))
                            }
                        case .standardError:
                            if let errorOutput = event.string(encoding: .utf8) {
                                FileHandle.standardError.write(Data(errorOutput.utf8))
                            }
                        }
                        continuation.yield(event)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    /// Awaits for the completion of the stream.
    public func awaitCompletion() async throws {
        for try await _ in self {
            // Do nothing, just consume the stream
        }
    }
}
