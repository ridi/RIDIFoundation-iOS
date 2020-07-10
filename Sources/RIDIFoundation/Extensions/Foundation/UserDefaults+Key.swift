import Foundation

extension UserDefaults {
    public struct Key<Value: Codable>: Hashable, Equatable, RawRepresentable {
        public var rawValue: String
        public var defaultValue: Value

        public init(_ rawValue: String, defaultValue: Value) {
            self.rawValue = rawValue
            self.defaultValue = defaultValue
        }

        #if swift(>=5.3)
        public init(_ rawValue: String, defaultValue: Value = nil) where Value: ExpressibleByNilLiteral {
            self.rawValue = rawValue
            self.defaultValue = defaultValue
        }

        public init?(rawValue: String) where Value: ExpressibleByNilLiteral {
            self.rawValue = rawValue
            self.defaultValue = nil
        }
        #endif

        public init?(rawValue: String) {
            return nil
        }
    }
}

extension UserDefaults {
    open subscript<T>(key: Key<T>) -> T {
        get {
            return object(forKey: key.rawValue) as? T ?? key.defaultValue
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }

    open func ridi_removeObject<T>(forKey key: Key<T>) {
        removeObject(forKey: key.rawValue)
    }

    open func ridi_objectIsForced<T>(forKey key: Key<T>) -> Bool {
        objectIsForced(forKey: key.rawValue)
    }

    open func ridi_objectIsForced<T>(forKey key: Key<T>, inDomain domain: String) -> Bool {
        objectIsForced(forKey: key.rawValue, inDomain: domain)
    }
}
