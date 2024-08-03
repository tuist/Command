import Foundation

/// Type that ensures thread-safe access to the underlying value using DispatchQueue.
public final class ThreadSafe<T>: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.threadsafety.queue", attributes: .concurrent)
    private var _value: T

    /// Returns the value boxed by `ThreadSafe`
    public var value: T {
        withValue { $0 }
    }

    /**
     Mutates in place the value boxed by `ThreadSafe`

     Example:
     ```
     let array = ThreadSafe([1,2,3])
     array.mutate { $0.append(4) }
     ```
     - Parameter with : block used to mutate the underlying value
     */
    @discardableResult
    public func mutate<Result>(_ body: (inout T) throws -> Result) rethrows -> Result {
        try queue.sync(flags: .barrier) {
            try body(&_value)
        }
    }

    /// Like `mutate`, but passes the value as readonly, returning the result of the closure.
    ///
    /// Example:
    /// ```
    /// let array = ThreadSafe([1, 2, 3])
    /// let sum = array.withValue { $0.reduce(0, +) } // 6
    /// ```
    public func withValue<Result>(_ body: (T) throws -> Result) rethrows -> Result {
        try queue.sync {
            try body(_value)
        }
    }

    /**

     Example:
     ```
     let array = ThreadSafe([1,2,3]) // ThreadSafe<Array<Int>>
     let optional = ThreadSafe<Int?>(nil)
     let optionalString: ThreadSafe<String?> = ThreadSafe("Initial Value")
     ```

     - Parameter initial : initial value used within the Atomic box
     */
    public init(_ initial: T) { _value = initial }
}
