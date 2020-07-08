// swiftlint:disable function_default_parameter_at_end
import Foundation

public protocol UserDefaultsBindable {
    associatedtype ValueType: Codable

    var userDefaults: UserDefaults { get }
    var key: UserDefaults.Key<ValueType> { get }

    var wrappedValue: ValueType { get }
}

extension UserDefaultsBindable {
    public var hasPersistentValue: Bool {
        return userDefaults.object(forKey: key.rawValue) != nil
    }

    public func removePersistentValue() {
        userDefaults.ridi_removeObject(forKey: key)
    }
}

extension UserDefaults {
    @propertyWrapper
    open class Binding<Value: Codable>: UserDefaultsBindable {
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

        public init(wrappedValue: Value, key: String, userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
            self.key = .init(key, defaultValue: wrappedValue)
        }

        public init(key: Key<Value>, userDefaults: UserDefaults = .standard) {
            self.userDefaults = userDefaults
            self.key = key
        }
    }
}

#if canImport(Combine)
import Combine

@available(macOS 10.15, iOS 13.0, *)
extension UserDefaults {
    struct BindingPublisher<Binding: UserDefaultsBindable>: Publisher {
        typealias Output = Binding.ValueType
        typealias Failure = Never

        class BindingSubscription<Binding: UserDefaultsBindable, S: Subscriber>: Subscription
        where S.Input == Binding.ValueType, S.Failure == Never {

            private var observation: UserDefaults.KeyValueObservation<Binding.ValueType>?
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

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Binding.ValueType == S.Input {
            let subscription = BindingSubscription(binding: binding, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

@available(macOS 10.15, iOS 13.0, *)
public protocol ObservableUserDefaultsBindable: UserDefaultsBindable, ObservableObject {

}

@available(macOS 10.15, iOS 13.0, *)
extension ObservableUserDefaultsBindable {
    public var objectWillChange: AnyPublisher<Void, Never> {
        publisher
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    public var publisher: AnyPublisher<ValueType, Never> {
        UserDefaults.BindingPublisher(binding: self).eraseToAnyPublisher()
    }
}

@available(macOS 10.15, iOS 13.0, *)
extension UserDefaults.Binding: ObservableUserDefaultsBindable {}

#endif
