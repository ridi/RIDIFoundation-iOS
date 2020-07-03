import Foundation

extension UserDefaults {
    struct _DecodableJSONRoot<T: Decodable>: Decodable {
         let root: T
     }

     struct _EncodableJSONRoot<T: Encodable>: Encodable {
         let root: T
     }

    open func ridi_object<T>(forKey defaultName: String) throws -> T? where T: Decodable {
        let value: Any? = object(forKey: defaultName)

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

    open func ridi_set<T>(_ value: T?, forKey defaultName: String) throws where T: Encodable {
        switch value {
        case let value as NSNumber:
            set(value, forKey: defaultName)
        case let value as NSString:
            set(value, forKey: defaultName)
        case let value as NSDate:
            set(value, forKey: defaultName)
        default:
            let archiver = NSKeyedArchiver(requiringSecureCoding: true)
            try archiver.encodeEncodable(value, forKey: NSKeyedArchiveRootObjectKey)
            let data = archiver.encodedData

            set(data, forKey: defaultName)
        }
    }
}
