import Foundation

protocol PropertyListRepresentable {}

extension Data: PropertyListRepresentable {}
extension String: PropertyListRepresentable {}
extension Date: PropertyListRepresentable {}
extension Int: PropertyListRepresentable {}
extension Float: PropertyListRepresentable {}
extension Double: PropertyListRepresentable {}
extension Bool: PropertyListRepresentable {}

extension Array: PropertyListRepresentable where Element: PropertyListRepresentable {}
extension Dictionary: PropertyListRepresentable
where Key: PropertyListRepresentable, Value: PropertyListRepresentable {}

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
    struct _DecodableJSONRoot<T: Decodable>: Decodable {
        let root: T
    }

    struct _EncodableJSONRoot<T: Encodable>: Encodable {
        let root: T
    }

    static func decode<T: Decodable>(_ value: Any?) throws -> T? {
        if let value = value as? T {
            return value
        }

        guard let data = value as? Data else {
            return nil
        }

        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            return unarchiver.decodeDecodable(T.self, forKey: NSKeyedArchiveRootObjectKey)
        } catch let originalError {
            do {
                return try JSONDecoder().decode(_DecodableJSONRoot<T>.self, from: data).root
            } catch {
                throw originalError
            }
        }
    }

    static func encode<T: Encodable>(_ value: T?) throws -> Any? {
        switch value {
        case let value as PropertyListRepresentable:
            return value
        default:
            let archiver = NSKeyedArchiver(requiringSecureCoding: true)
            try archiver.encodeEncodable(value, forKey: NSKeyedArchiveRootObjectKey)

            return archiver.encodedData
        }
    }
}

extension UserDefaults {
    open func ridi_object<T>(forKey defaultName: String) throws -> T? where T: Decodable {
       let value: Any? = object(forKey: defaultName)

       return try Self.decode(value)
    }

    open func ridi_set<T>(_ value: T?, forKey defaultName: String) throws where T: Encodable {
       return try set(Self.encode(value), forKey: defaultName)
    }

    open func ridi_object<T>(forKey key: Key<T>) throws -> T where T: Decodable {
       try ridi_object(forKey: key.rawValue) ?? key.defaultValue
    }

    open func ridi_set<T>(_ value: T?, forKey key: Key<T>) throws where T: Encodable {
       try ridi_set(value, forKey: key.rawValue)
    }

    open subscript<T>(key: Key<T>) -> T? {
        get {
            return try? ridi_object(forKey: key.rawValue)
        }
        set {
            try! ridi_set(newValue, forKey: key.rawValue)
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
