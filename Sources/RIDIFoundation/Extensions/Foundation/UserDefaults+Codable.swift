import Foundation

extension UserDefaults {
    open func ridi_object<T>(forKey defaultName: String) throws -> T? where T: Decodable {
        let value: Any? = object(forKey: defaultName)

        switch value {
        case let value as NSNumber:
            return value as? T
        case let value as NSString:
            return value as? T
        case let value as NSDate:
            return value as? T
        case let value?:
            let data = try PropertyListSerialization.data(fromPropertyList: value, format: .binary, options: 0)

            let decoder = PropertyListDecoder()
            return try decoder.decode(T.self, from: data)
        case .none:
            return nil
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
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(value)

            set(try PropertyListSerialization.propertyList(from: data, options: [], format: nil), forKey: defaultName)
        }
    }
}
