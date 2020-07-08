import Foundation

protocol PropertyListRepresentable {}

extension String: PropertyListRepresentable {}
extension Int: PropertyListRepresentable {}
extension Float: PropertyListRepresentable {}
extension Date: PropertyListRepresentable {}

extension Array: PropertyListRepresentable where Element: PropertyListRepresentable {}
extension Dictionary: PropertyListRepresentable where Key: PropertyListRepresentable, Value: PropertyListRepresentable {}

extension UserDefaults {
struct _DecodableJSONRoot<T: Decodable>: Decodable {
        let root: T
    }

    struct _EncodableJSONRoot<T: Encodable>: Encodable {
        let root: T
    }

    static func decode<T: Decodable>(_ value: Any?) throws -> T? {
        switch value {
        case let value as PropertyListRepresentable:
            return value as? T
        case let value as NSNumber:
            return value as? T
        case let value as NSString:
            return value as? T
        case let value as NSDate:
            return value as? T
        case let value as NSArray:
            return value as? T
        case let value as NSDictionary:
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

    open func ridi_object<T>(forKey defaultName: String) throws -> T? where T: Decodable {
        let value: Any? = object(forKey: defaultName)

        return try Self.decode(value)
    }

    open func ridi_set<T>(_ value: T?, forKey defaultName: String) throws where T: Encodable {
        return try set(Self.encode(value), forKey: defaultName)
    }
}
