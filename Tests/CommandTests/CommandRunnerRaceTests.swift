import Mockable
import Testing
@testable import Command

struct CommandRunnerRaceTests {
    @Test func runsManyConcurrent_successfully() async throws {
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
    }
}
