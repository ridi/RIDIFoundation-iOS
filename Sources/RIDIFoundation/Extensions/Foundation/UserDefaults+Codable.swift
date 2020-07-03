import Foundation

extension UserDefaults {
struct _DecodableJSONRoot<T: Decodable>: Decodable {
        let root: T
    }

    struct _EncodableJSONRoot<T: Encodable>: Encodable {
        let root: T
    }

    static func _decode<T: Decodable>(_ value: Any?) throws -> T? {
        switch value {
        case let value as NSNumber:
            return value as? T
        case let value as NSString:
            return value as? T
        case let value as NSDate:
            return value as? T
        case let value:
            guard let data = value as? Data else {
                return nil
            }

            do {
                let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
                return unarchiver.decodeDecodable(T.self, forKey: NSKeyedArchiveRootObjectKey)
            } catch let originalError {
                guard let data = value as? Data else {
                    throw originalError
                }

                do {
                    return try JSONDecoder().decode(_DecodableJSONRoot<T>.self, from: data).root
                } catch {
                    throw originalError
                }
            }
        }
    }

    static func _encode<T: Encodable>(_ value: T?) throws -> Any? {
        switch value {
        case let value as NSNumber:
            return value
        case let value as NSString:
            return value
        case let value as NSDate:
            return value
        default:
            let archiver = NSKeyedArchiver(requiringSecureCoding: true)
            try archiver.encodeEncodable(value, forKey: NSKeyedArchiveRootObjectKey)

            return archiver.encodedData
        }
    }

    open func ridi_object<T>(forKey defaultName: String) throws -> T? where T: Decodable {
        let value: Any? = object(forKey: defaultName)

        return try Self._decode(value)
    }

    open func ridi_set<T>(_ value: T?, forKey defaultName: String) throws where T: Encodable {
        return try set(Self._encode(value), forKey: defaultName)
    }
}
