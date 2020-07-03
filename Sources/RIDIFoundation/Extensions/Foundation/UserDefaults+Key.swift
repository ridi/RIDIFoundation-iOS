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
