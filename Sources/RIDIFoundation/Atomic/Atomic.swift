import Foundation

/// A property wrapper type that can guarantee that it can be safely read and written from different threads/queues.
@propertyWrapper
open class Atomic<Value> {
    private var _value: Value
    private let _queue: DispatchQueue

    /**
     Creates an atomic with an initial wrapped value.

     - Parameters:
        - wrappedValue: An initial value.
        - queue: A queue to confined on atomic operations. Can be nil.
     */
    public init(wrappedValue: Value, queue: DispatchQueue? = nil) {
        _value = wrappedValue
        _queue = DispatchQueue(
            label: String(describing: Self.self),
            qos: .unspecified,
            attributes: [.concurrent],
            autoreleaseFrequency: .inherit,
            target: queue
        )
    }

    /// The underlying value referenced by the atomic.
    open var wrappedValue: Value {
        get { _queue.performAndWait { _value } }
        set { perform { $0 = newValue } }
    }

    /// A projection of the atomic value that returns a atomic.
    open var projectedValue: Atomic<Value> {
        self
    }

    /// Asynchronously performs a given block atomically.
    ///
    /// - Parameters:
    ///     - block: The block to perform.
    open func perform(_ block: @escaping (inout Value) -> Void) {
        _queue.async(flags: [.barrier]) { [self] in block(&self._value) }
    }
}
