import Foundation
import Mockable
import Testing
@testable import Command

#if !os(Linux)
    struct CommandRunnerRaceTests {
        @Test func boundsConcurrentSubprocessLaunches() async throws {
            #if os(macOS)
                // Each running subprocess holds open pipe file descriptors, so an unbounded fan-out
                // can exhaust the process's file-descriptor table (surfacing as EBADF on launch).
                // The runner must cap how many subprocesses run at once; verify that cap holds.
                let limit = 4
                let commandRunner = CommandRunner(maximumConcurrentProcesses: limit)

                let directory = FileManager.default.temporaryDirectory
                    .appendingPathComponent("command-limiter-\(UUID().uuidString)")
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                defer { try? FileManager.default.removeItem(at: directory) }

                // Each command creates a marker file while it runs and removes it on exit, so the
                // number of marker files present at any instant equals the number of subprocesses
                // running concurrently.
                let maxObserved = ThreadSafe(0)
                let sampler = Task {
                    while !Task.isCancelled {
                        let count = (try? FileManager.default.contentsOfDirectory(atPath: directory.path))?.count ?? 0
                        maxObserved.mutate { $0 = max($0, count) }
                        try? await Task.sleep(nanoseconds: 2_000_000)
                    }
                }

                let script = "marker=\"\(directory.path)/$$\"; touch \"$marker\"; sleep 0.2; rm -f \"$marker\""
                await withTaskGroup(of: Void.self) { group in
                    for _ in 0 ..< 60 {
                        group.addTask {
                            do {
                                for try await _ in commandRunner.run(arguments: ["/bin/sh", "-c", script]) {}
                            } catch {}
                        }
                    }
                    await group.waitForAll()
                }
                sampler.cancel()

                #expect(maxObserved.value > 0, "Expected to observe running subprocesses")
                #expect(
                    maxObserved.value <= limit,
                    "Observed \(maxObserved.value) concurrent subprocesses, expected at most \(limit)"
                )
            #endif
        }

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
