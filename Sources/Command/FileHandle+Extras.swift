import Foundation

extension FileHandle {
    func byteStream() -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            self.readabilityHandler = { handle in
                let data = handle.availableData
                if data.isEmpty {
                    continuation.finish()
                    handle.readabilityHandler = nil
                } else {
                    continuation.yield(data)
                }
            }

            continuation.onTermination = { @Sendable _ in
                self.readabilityHandler = nil
            }
        }
    }
}
