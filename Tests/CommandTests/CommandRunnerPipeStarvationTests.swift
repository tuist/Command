import Foundation
import Testing
@testable import Command

#if !os(Linux)
    /// Regression coverage for tuist/tuist#12366 — `tuist install` deterministically hangs on
    /// low-core macOS CI VMs. The observable defect: at the instant the child subprocess starts,
    /// nothing is draining its stdout pipe yet, because the drainer is set up asynchronously from
    /// inside a `Task {}` that competes on the same cooperative pool that the parent is
    /// saturating. On a 3-vCPU CI VM that reader task loses the scheduling race, the pipe fills,
    /// the child blocks on `write`, and the runner never returns.
    ///
    /// Reproducing the timing race on a high-core dev box is unreliable — Swift's cooperative
    /// pool grows when tasks block and cycles through peers fast enough that the reader usually
    /// gets a slice before the child fills a pipe. This test forces the CI-VM ordering by keeping
    /// the cooperative pool busy cycling through many always-ready peer tasks. Under that
    /// congestion the reader task lands at the tail of the run queue and does not get a slice
    /// before the runner reaches `process.run()`, so the hook observes the pipes with no drainer
    /// attached — which is exactly the moment on real subprocesses when the child would begin
    /// writing to an unread pipe.
    struct CommandRunnerPipeStarvationTests {
        @Test func stdoutPipeIsDrainedBeforeProcessRuns_underCongestion() async throws {
            #if os(macOS)
                let peerCount = max(64, ProcessInfo.processInfo.activeProcessorCount * 4)
                let stopFlag = TestFlag()
                var peers: [Task<Void, Never>] = []
                peers.reserveCapacity(peerCount)
                for _ in 0 ..< peerCount {
                    peers.append(
                        Task {
                            while !stopFlag.isSet, !Task.isCancelled {
                                // Hold the pool worker for a fraction of a millisecond of CPU
                                // work between yields, so peers cycling through the queue do not
                                // hand off control fast enough for a newly-queued reader task to
                                // slip in before the runner reaches `process.run()`.
                                var accumulator: UInt64 = 0xDEAD_BEEF
                                for _ in 0 ..< 200_000 {
                                    accumulator = accumulator &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
                                }
                                blackHole(accumulator)
                                await Task.yield()
                            }
                        }
                    )
                }
                defer {
                    stopFlag.set()
                    for peer in peers { peer.cancel() }
                }

                // Let the pool actually start cycling through the peers before we hand it a
                // subprocess to drain, so the reader task lands at the tail of a busy queue.
                try await Task.sleep(nanoseconds: 150_000_000)

                let captured = ProcessAndPipesCapture()
                let commandRunner = CommandRunner(preProcessRunHook: captured.capture)

                _ = try await commandRunner.run(arguments: ["/bin/sh", "-c", "printf hi"])
                    .reduce("") { $0 + ($1.string() ?? "") }

                let snapshot = try #require(captured.value)
                #expect(
                    snapshot.stdoutHadReadabilityHandler,
                    "Runner started the subprocess before installing a drainer on the stdout pipe — under CI-VM cooperative-pool congestion the child would block on write once the pipe filled"
                )
                #expect(
                    snapshot.stderrHadReadabilityHandler,
                    "Runner started the subprocess before installing a drainer on the stderr pipe — under CI-VM cooperative-pool congestion the child would block on write once the pipe filled"
                )
            #endif
        }
    }

    /// Captures whether the stdout/stderr pipe drainers were already attached at the moment
    /// `process.run()` was about to fire the child. The runner calls it synchronously from the
    /// same code path that installs the pipes and starts the process, so no cross-thread
    /// synchronisation is needed beyond the storage lock.
    final class ProcessAndPipesCapture: @unchecked Sendable {
        struct Snapshot {
            let stdoutHadReadabilityHandler: Bool
            let stderrHadReadabilityHandler: Bool
        }

        private let lock = NSLock()
        private var snapshot: Snapshot?

        var value: Snapshot? {
            lock.lock()
            defer { lock.unlock() }
            return snapshot
        }

        @Sendable func capture(stdout: Pipe, stderr: Pipe) {
            let stdoutHandler = stdout.fileHandleForReading.readabilityHandler
            let stderrHandler = stderr.fileHandleForReading.readabilityHandler
            lock.lock()
            snapshot = Snapshot(
                stdoutHadReadabilityHandler: stdoutHandler != nil,
                stderrHadReadabilityHandler: stderrHandler != nil
            )
            lock.unlock()
        }
    }

    /// Prevents the compiler from optimising away the CPU work each peer does between yields.
    @inline(never)
    private func blackHole(_ value: UInt64) {
        _ = value
    }

    /// Sendable flag guarded by an NSLock. Lets the peer tasks exit cleanly at the end of the
    /// test instead of running until `Task.isCancelled` propagates through the pool.
    private final class TestFlag: @unchecked Sendable {
        private var flag = false
        private let lock = NSLock()

        var isSet: Bool {
            lock.lock()
            defer { lock.unlock() }
            return flag
        }

        func set() {
            lock.lock()
            flag = true
            lock.unlock()
        }
    }
#endif
