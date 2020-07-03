// swiftlint:disable function_default_parameter_at_end
import Foundation

public protocol UserDefaultsBindable {
    associatedtype ValueType

    var userDefaults: UserDefaults { get }
    var key: UserDefaults.Key<ValueType> { get }

    var wrappedValue: ValueType { get }
}

extension UserDefaultsBindable {
    public var hasPersistentValue: Bool {
        return userDefaults.object(forKey: key.rawValue) != nil
    }

    public func removePersistentValue() {
        userDefaults.removeObject(forKey: key)
    }
}

// MARK: -

private protocol OptionalProtocol {
    func isNil() -> Bool
}

extension Optional : OptionalProtocol {
    fileprivate func isNil() -> Bool {
        return self == nil
    }
}

extension UserDefaults {
    @propertyWrapper
    open class Binding<T>: UserDefaultsBindable {
        public let userDefaults: UserDefaults
        public let key: Key<T>
        public let defaultValue: T

        open var wrappedValue: T {
            get {
                return userDefaults[key] ?? defaultValue
            }
            set {
                if let value = newValue as? OptionalProtocol, value.isNil() {
                    userDefaults.removeObject(forKey: key)
                } else {
                    userDefaults[key] = newValue
                }
            }
        }

        open var projectedValue: Binding<T> {
            return self
        }

        public init(userDefaults: UserDefaults = .standard, key: Key<T>, defaultValue: T) {
            checkCodable(T.self)
            self.userDefaults = userDefaults
            self.key = key
            self.defaultValue = defaultValue
        }
    }

    @propertyWrapper
    open class LazyBinding<T>: UserDefaultsBindable {
        public let userDefaults: UserDefaults
        public let key: Key<T>
        public let defaultValue: () -> T

        open var wrappedValue: T {
            get {
                return userDefaults[key] ?? defaultValue()
            }
            set {
                if let value = newValue as? OptionalProtocol, value.isNil() {
                    userDefaults.removeObject(forKey: key)
                } else {
                    userDefaults[key] = newValue
                }
            }
        }

        open var projectedValue: LazyBinding<T> {
            return self
        }

        public init(userDefaults: UserDefaults = .standard, key: Key<T>, defaultValue: @autoclosure @escaping () -> T) {
            checkCodable(T.self)
            self.userDefaults = userDefaults
            self.key = key
            self.defaultValue = defaultValue
        }
    }

    @propertyWrapper
    open class CodableBinding<T: Codable>: UserDefaultsBindable {
        public let userDefaults: UserDefaults
        public let key: Key<T>
        public let defaultValue: T

        open var wrappedValue: T {
            get {
                do {
                    return try userDefaults.object(forKey: key) ?? defaultValue
                } catch {
                    debugPrint(
                        "⚠️ Decodable failure anomaly was detected.\n" +
                        "  Debugging: To debug this issue you can set a breakpoint in \(#file):\(#line) and observe the call stack.\n" +
                        "  Error: \(error)\n" +
                        "  Key: \(key)\n" +
                        "  Fallback: \(defaultValue)\n"
                    )
                    return defaultValue
                }
            }
            set {
                do {
                    try userDefaults.set(newValue, forKey: key)
                } catch {
                    debugPrint(
                        "⚠️ Encodable failure anomaly was detected.\n" +
                        "  Debugging: To debug this issue you can set a breakpoint in \(#file):\(#line) and observe the call stack.\n" +
                        "  Error: \(error)\n" +
                        "  Key: \(key)\n" +
                        "  Value: \(newValue)\n"
                    )
                }
            }
        }

        open var projectedValue: CodableBinding<T> {
            return self
        }

        public init(userDefaults: UserDefaults = .standard, key: Key<T>, defaultValue: T) {
            self.userDefaults = userDefaults
            self.key = key
            self.defaultValue = defaultValue
        }
    }
}

private func checkCodable<T>(_ type: T) {
    assert(
        [
            Int.self,
            Float.self,
            Double.self,
            Bool.self,
            Data.self,
            Date.self,
            String.self,
            URL.self,
            Optional<Int>.self,
            Optional<Float>.self,
            Optional<Double>.self,
            Optional<Bool>.self,
            Optional<Data>.self,
            Optional<Date>.self,
            Optional<String>.self,
            Optional<URL>.self,
            [String].self,
            [String: Any].self,
            NSObject.self,
            [NSObject.self]
        ].contains(where: { $0 is T }),
        "⚠️ Codable do not support yet.\n" +
        "  Use UserDefaults.CodableBinding instead or use UserDefaults.object(forKey:) or UserDefaults.set(_:forKey:).\n"
    )
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

@available(macOS 10.15, iOS 13.0, *)
extension UserDefaults.LazyBinding: ObservableUserDefaultsBindable {}

@available(macOS 10.15, iOS 13.0, *)
extension UserDefaults.CodableBinding: ObservableUserDefaultsBindable {}

#endif
