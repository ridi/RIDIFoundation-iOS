// swiftlint:disable function_default_parameter_at_end
import Foundation

extension UserDefaults {
    public struct Key<Value>: Hashable, Equatable, RawRepresentable {
        public var rawValue: String

        public init(_ rawValue: String, valueType: Value.Type) {
            self.init(rawValue)
        }

        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension UserDefaults {
    open subscript<T>(key: Key<T>) -> T? {
        get {
            return object(forKey: key.rawValue) as? T
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open subscript(key: Key<Int>) -> Int {
        get {
            return integer(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open subscript(key: Key<Float>) -> Float {
        get {
            return float(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open subscript(key: Key<Double>) -> Double {
        get {
            return double(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open subscript(key: Key<Bool>) -> Bool {
        get {
            return bool(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open subscript<T>(key: Key<[T]>) -> [T]? {
        get {
            return array(forKey: key.rawValue) as? [T]
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open subscript<T, U>(key: Key<[T: U]>) -> [T: U]? {
        get {
            return dictionary(forKey: key.rawValue) as? [T: U]
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open subscript(key: Key<Data>) -> Data? {
        get {
            return data(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open subscript(key: Key<[String]>) -> [String]? {
        get {
            return stringArray(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open subscript(key: Key<URL>) -> URL? {
        get {
            return url(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open subscript<T>(key: Key<T>) -> T? where T: LosslessStringConvertible {
        get {
            string(forKey: key.rawValue).flatMap { T($0) }
        }
        set {
            set(newValue?.description, forKey: key.rawValue)
        }
    }

    private struct JSONRoot<T: Codable>: Codable {
        let root: T
    }

    open func object<T>(forKey key: Key<T>) throws -> T? where T: Codable {
        let decoder = JSONDecoder()

        return try data(forKey: key.rawValue).flatMap {
            try decoder.decode(JSONRoot<T>.self, from: $0).root
        }
    }

    open func set<T>(_ value: T?, forKey key: Key<T>) throws where T: Codable {
        let encoder = JSONEncoder()

        set(
            try value.flatMap { try encoder.encode(JSONRoot<T>(root: $0)) },
            forKey: key.rawValue
        )
    }

    open func removeObject<T>(forKey key: Key<T>) {
        removeObject(forKey: key.rawValue)
    }

    open func objectIsForced<T>(forKey key: Key<T>) -> Bool {
        objectIsForced(forKey: key.rawValue)
    }

    open func objectIsForced<T>(forKey key: Key<T>, inDomain domain: String) -> Bool {
        objectIsForced(forKey: key.rawValue, inDomain: domain)
    }
}

public protocol UserDefaultsBindable {
    associatedtype ValueType

    var userDefaults: UserDefaults { get }
    var key: UserDefaults.Key<ValueType> { get }
}

extension UserDefaultsBindable {
    public var hasPersistentValue: Bool {
        return userDefaults.object(forKey: key.rawValue) != nil
    }

    public func removePersistentValue() {
        userDefaults.removeObject(forKey: key)
    }
}

// MARK: - Observation

extension UserDefaults {
    public struct KeyValueObservedChange<Value> {
        public typealias Kind = NSKeyValueChange

        public let kind: KeyValueObservedChange<Value>.Kind

        ///newValue and oldValue will only be non-nil if .new/.old is passed to `observe()`.
        ///In general, get the most up to date value by accessing it directly on the observed object instead.
        public let newValue: Value?

        public let oldValue: Value?

        ///indexes will be nil unless the observed KeyPath refers to an ordered to-many property
        public let indexes: IndexSet?

        ///'isPrior' will be true if this change observation is being sent before the change happens,
        ///due to .prior being passed to `observe()`
        public let isPrior: Bool
    }

    public class KeyValueObservation<Value>: NSObject {
        private unowned let userDefaults: UserDefaults
        private let key: Key<Value>
        private var changeHandler: (UserDefaults, KeyValueObservedChange<Value>) -> Void

        init(
            userDefaults: UserDefaults = .standard,
            key: Key<Value>, options: NSKeyValueObservingOptions,
            changeHandler: @escaping (UserDefaults, KeyValueObservedChange<Value>) -> Void
        ) {
            self.userDefaults = userDefaults
            self.changeHandler = changeHandler
            self.key = key
            super.init()
            userDefaults.addObserver(self, forKeyPath: key.rawValue, options: options, context: nil)
        }

        public override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            guard let change = change, object != nil, keyPath == key.rawValue else { return }
            changeHandler(
                userDefaults,
                KeyValueObservedChange(
                    kind: NSKeyValueChange(rawValue: change[.kindKey] as! UInt)!,
                    newValue: change[.newKey] as? Value,
                    oldValue: change[.oldKey] as? Value,
                    indexes: change[.indexesKey] as? IndexSet,
                    isPrior: change[.notificationIsPriorKey] as? Bool == true
                )
            )
        }

        deinit {
            userDefaults.removeObserver(self, forKeyPath: key.rawValue, context: nil)
        }
    }

    public func observe<Value>(
        _ key: Key<Value>,
        options: NSKeyValueObservingOptions = [.new],
        changeHandler: @escaping (UserDefaults, KeyValueObservedChange<Value>) -> Void
    ) -> UserDefaults.KeyValueObservation<Value> {
        KeyValueObservation<Value>(userDefaults: self, key: key, options: options, changeHandler: changeHandler)
    }
}

extension UserDefaultsBindable {
    public func observe(
        options: NSKeyValueObservingOptions = [.new],
        _ changeHandler: @escaping (Self, UserDefaults.KeyValueObservedChange<ValueType>) -> Void
    ) -> UserDefaults.KeyValueObservation<ValueType> {
        userDefaults.observe(self.key, options: options) {
            changeHandler(self, $1)
        }
    }
}

// MARK: -

extension UserDefaults {
    @propertyWrapper
    public struct Binding<T>: UserDefaultsBindable {
        public let userDefaults: UserDefaults
        public let key: Key<T>
        public let defaultValue: T

        public var wrappedValue: T {
            get {
                return userDefaults[key] ?? defaultValue
            }
            set {
                return userDefaults[key] = newValue
            }
        }

        public var projectedValue: Binding<T> {
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
    public struct LazyBinding<T>: UserDefaultsBindable {
        public let userDefaults: UserDefaults
        public let key: Key<T>
        public let defaultValue: () -> T

        public var wrappedValue: T {
            get {
                return userDefaults[key] ?? defaultValue()
            }
            set {
                return userDefaults[key] = newValue
            }
        }

        public var projectedValue: LazyBinding<T> {
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
    public struct OptionalBinding<T>: UserDefaultsBindable {
        public let userDefaults: UserDefaults
        public let key: Key<T>

        public var wrappedValue: T? {
            get {
                guard hasPersistentValue else {
                    return nil
                }

                return userDefaults[key]
            }
            set {
                return userDefaults[key] = newValue
            }
        }

        public var projectedValue: OptionalBinding<T> {
            return self
        }

        public init(userDefaults: UserDefaults = .standard, key: Key<T>) {
            checkCodable(T.self)
            self.userDefaults = userDefaults
            self.key = key
        }
    }

    @propertyWrapper
    public struct CodableBinding<T: Codable>: UserDefaultsBindable {
        public let userDefaults: UserDefaults
        public let key: Key<T>
        public let defaultValue: T

        public var wrappedValue: T {
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

        public var projectedValue: CodableBinding<T> {
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
            LosslessStringConvertible.self,
            [Any].self,
            [String].self,
            [String: Any].self,
            NSObject.self
        ].contains(where: { $0 is T }),
        "⚠️ Codable do not support yet.\n" +
        "  Use UserDefaults.CodableBinding instead or use UserDefaults.object(forKey:) or UserDefaults.set(_:forKey:).\n"
    )
}
