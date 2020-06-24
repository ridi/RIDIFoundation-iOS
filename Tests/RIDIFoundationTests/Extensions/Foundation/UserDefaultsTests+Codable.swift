@testable import RIDIFoundation
import XCTest

extension UserDefaultsTests {
    func testSetCodable() throws {
        struct Test: Codable, Equatable {
            var a = UUID()
            var b = URL(fileURLWithPath: "/")
        }

        let key = UUID().uuidString
        let value = Test()

        try userDefaults.ridi_set(value, forKey: key)


        let propertyListEncoder = PropertyListEncoder()
        let propertyListObject = try PropertyListSerialization.propertyList(from: propertyListEncoder.encode(value), options: [], format: nil)

        XCTAssertEqual(
            (UserDefaults.standard.object(forKey: key) as Any?) as! NSObject,
            propertyListObject as! NSObject
        )
    }

    func testSetStringAsCodable() throws {
        let key = UUID().uuidString
        let value = UUID().uuidString

        try userDefaults.ridi_set(value, forKey: key)

        XCTAssertEqual(
            (userDefaults.object(forKey: key) as Any?) as! NSObject,
            value as NSObject
        )
    }

    func testSetIntAsCodable() throws {
        let key = UUID().uuidString
        let value = Int.random(in: Int.min...Int.max)

        try userDefaults.ridi_set(value, forKey: key)

        XCTAssertEqual(
            (userDefaults.object(forKey: key) as Any?) as! NSObject,
            value as NSObject
        )
    }

    func testSetDateAsCodable() throws {
        let key = UUID().uuidString
        let value = Date(
            timeIntervalSince1970: .random(in: TimeInterval.leastNormalMagnitude...TimeInterval.greatestFiniteMagnitude)
        )

        try userDefaults.ridi_set(value, forKey: key)

        XCTAssertEqual(
            (userDefaults.object(forKey: key) as Any?) as! NSObject,
            value as NSObject
        )
    }

    func testGetCodable() throws {
        struct Test: Codable, Equatable {
            var a = UUID()
            var b = URL(fileURLWithPath: "/")
        }

        let key = UUID().uuidString
        let value = Test()

        let propertyListEncoder = PropertyListEncoder()
        let propertyListObject = try PropertyListSerialization.propertyList(from: propertyListEncoder.encode(value), options: [], format: nil)

        userDefaults.set(propertyListObject, forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as Test?,
            value
        )
    }

    func testGetStringAsCodable() throws {
        struct Test: Codable, Equatable {
            var a = UUID()
            var b = URL(fileURLWithPath: "/")
        }

        let key = UUID().uuidString
        let value = UUID().uuidString

        userDefaults.set(value, forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as String?,
            value
        )
    }

    func testGetIntAsCodable() throws {
        struct Test: Codable, Equatable {
            var a = UUID()
            var b = URL(fileURLWithPath: "/")
        }

        let key = UUID().uuidString
        let value = Int.random(in: Int.min...Int.max)

        userDefaults.set(value, forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as Int?,
            value
        )
    }

    func testGetDateAsCodable() throws {
        struct Test: Codable, Equatable {
            var a = UUID()
            var b = URL(fileURLWithPath: "/")
        }

        let key = UUID().uuidString
        let value = Date(
            timeIntervalSince1970: .random(in: TimeInterval.leastNormalMagnitude...TimeInterval.greatestFiniteMagnitude)
        )

        userDefaults.set(value, forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as Date?,
            value
        )
    }
}
