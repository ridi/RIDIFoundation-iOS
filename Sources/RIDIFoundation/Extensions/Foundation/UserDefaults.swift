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

    open func object<T>(forKey key: Key<T>) throws -> T? where T: Decodable {
        let decoder = PropertyListDecoder()

        return try data(forKey: key.rawValue).flatMap {
            try decoder.decode(T.self, from: $0)
        }
    }

    open func set<T>(_ value: T?, forKey key: Key<T>) throws where T: Encodable {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary

        set(
            try value.flatMap { try encoder.encode($0) },
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
            self.userDefaults = userDefaults
            self.key = key
        }
    }
}
