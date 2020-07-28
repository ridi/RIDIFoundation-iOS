import Foundation

extension UserDefaults {
    @propertyWrapper
    open class Binding<Value: Codable> {
        public let userDefaults: UserDefaults
        public let key: Key<Value>

        open var wrappedValue: Value {
            get {
                return try! userDefaults.ridi_object(forKey: key)
            }
            set {
                try! userDefaults.ridi_set(newValue, forKey: key)
            }
        }

        open var projectedValue: Binding<Value> {
            return self
        }

        open var hasPersistentValue: Bool {
            return userDefaults.object(forKey: key.rawValue) != nil
        }

        public init(wrappedValue: Value, key: String, userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
            self.key = .init(key, defaultValue: wrappedValue)
        }

        public init(key: Key<Value>, userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
            self.key = key
        }

        open func removePersistentValue() {
            userDefaults.ridi_removeObject(forKey: key)
        }
    }
}

#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, *)
extension UserDefaults.Binding {
    struct BindingPublisher<Output, Binding: UserDefaults.Binding<Output>>: Publisher {
        typealias Failure = Never

        class BindingSubscription<Value, Binding: UserDefaults.Binding<Value>, S: Subscriber>: Subscription
        where S.Input == Value, S.Failure == Never {

            private var observation: UserDefaults.KeyValueObservation<Value>?
            private var subscriber: S?

            init(binding: Binding, subscriber: S) {
                self.subscriber = subscriber
                self.observation = binding.observe(options: [.prior], { [weak self] _, change in
                    guard let self = self else {
                        return
                    }

                    guard change.isPrior else {
                        return
                    }

                    _ = self.subscriber?.receive(binding.wrappedValue)
                })
            }

            func request(_ demand: Subscribers.Demand) {}

            func cancel() {
                observation = nil
                subscriber = nil
            }
        }

        let binding: Binding

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = BindingSubscription(binding: binding, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }

    public var publisher: AnyPublisher<Value, Never> {
        BindingPublisher(binding: self).eraseToAnyPublisher()
    }
}

@available(macOS 10.15, iOS 13.0, *)
extension UserDefaults.Binding: ObservableObject {
    public var objectWillChange: AnyPublisher<Void, Never> {
        publisher
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
#endif
