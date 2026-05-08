import Mockable
import Testing
@testable import Command

#if !os(Linux)
    struct CommandRunnerRaceTests {
        @Test func runsManyConcurrent_successfully() async throws {
            #if os(Linux) || os(macOS)
                let commandRunner = CommandRunner()

                try await withThrowingTaskGroup(of: String.self) { group in
                    for _ in 0 ..< 1000 {
                        group.addTask {
                            try await commandRunner
                                .run(arguments: ["echo", "test"])
                                .reduce("") { $0 + ($1.string() ?? "") }
                        }
                    }

                    for try await result in group {
                        #expect(result == "test\n")
                    }
                }
            #endif
        }

        @Test func runsManyConcurrentCommandsWithLargeOutput_successfully() async throws {
            #if os(macOS)
                let commandRunner = CommandRunner()
                let byteCount = 256 * 1024
                let shellCommand = """
                dd if=/dev/zero bs=1024 count=256 2>/dev/null
                dd if=/dev/zero bs=1024 count=256 1>&2 2>/dev/null
                """

                try await withThrowingTaskGroup(of: (standardOutput: Int, standardError: Int).self) { group in
                    for _ in 0 ..< 64 {
                        group.addTask {
                            try await commandRunner
                                .run(arguments: ["/bin/sh", "-c", shellCommand])
                                .reduce(into: (standardOutput: 0, standardError: 0)) { counts, event in
                                    switch event {
                                    case let .standardOutput(bytes):
                                        counts.standardOutput += bytes.count
                                    case let .standardError(bytes):
                                        counts.standardError += bytes.count
                                    }
                                }
                        }
                    }

                    for try await result in group {
                        #expect(result.standardOutput == byteCount)
                        #expect(result.standardError == byteCount)
                    }
                }
            #endif
        }
    }
#endif
