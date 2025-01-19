import Mockable
import XCTest
@testable import Command

final class CommandRunnerRaceTests: XCTestCase {
    func test_runsManyConcurrent_successful() async throws {
        let commandRunner = CommandRunner()

        try await withThrowingTaskGroup(of: String.self) { group in    
            for _ in 0..<1000 {
                group.addTask {
                    return try await commandRunner
                        .run(arguments: ["echo", "test"])
                        .reduce("") { $0 + ($1.string() ?? "") }
                }
            }

            for try await result in group {
                XCTAssertEqual(result, "test\n")
            }
        }
    }
}
