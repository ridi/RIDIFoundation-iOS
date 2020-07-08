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

        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        try archiver.encodeEncodable(value, forKey: NSKeyedArchiveRootObjectKey)

        XCTAssertEqual(
            (UserDefaults.standard.object(forKey: key) as Any?) as! Data,
            archiver.encodedData
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

    func testSetStringArrayAsCodable() throws {
        let key = UUID().uuidString
        let value = (0..<50).map { _ in UUID().uuidString }

        try userDefaults.ridi_set(value, forKey: key)

        XCTAssertEqual(
            (userDefaults.object(forKey: key) as Any?) as! NSObject,
            value as NSObject
        )
    }

    func testSetIntArrayAsCodable() throws {
        let key = UUID().uuidString
        let value = (0..<50).map { _ in Int.random(in: Int.min...Int.max) }

        try userDefaults.ridi_set(value, forKey: key)

        XCTAssertEqual(
            (userDefaults.object(forKey: key) as Any?) as! NSObject,
            value as NSObject
        )
    }

    func testSetDateArrayAsCodable() throws {
        let key = UUID().uuidString
        let value = (0..<50).map { _ in
            Date(
                timeIntervalSince1970: .random(in: TimeInterval.leastNormalMagnitude...TimeInterval.greatestFiniteMagnitude)
            )
        }

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

        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        try archiver.encodeEncodable(value, forKey: NSKeyedArchiveRootObjectKey)

        userDefaults.set(archiver.encodedData, forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as Test?,
            value
        )
    }

    func testGetOldCodable() throws {
        struct Test: Codable, Equatable {
            var a = UUID()
            var b = URL(fileURLWithPath: "/")
        }

        let key = UUID().uuidString
        let value = Test()

        let jsonEncoder = JSONEncoder()

        try userDefaults.set(jsonEncoder.encode(UserDefaults._EncodableJSONRoot(root: value)), forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as Test?,
            value
        )
    }

    func testGetStringAsCodable() throws {
        let key = UUID().uuidString
        let value = UUID().uuidString

        userDefaults.set(value, forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as String?,
            value
        )
    }

    func testGetIntAsCodable() throws {
        let key = UUID().uuidString
        let value = Int.random(in: Int.min...Int.max)

        userDefaults.set(value, forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as Int?,
            value
        )
    }

    func testGetDateAsCodable() throws {
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

    func testGetStringArrayAsCodable() throws {
        let key = UUID().uuidString
        let value = (0..<50).map { _ in UUID().uuidString }

        userDefaults.set(value, forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as [String]?,
            value
        )
    }

    func testGetIntArrayAsCodable() throws {
        let key = UUID().uuidString
        let value = (0..<50).map { _ in Int.random(in: Int.min...Int.max) }

        userDefaults.set(value, forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as [Int]?,
            value
        )
    }

    func testGetDateArrayAsCodable() throws {
        let key = UUID().uuidString
        let value = (0..<50).map { _ in
            Date(
                timeIntervalSince1970: .random(in: TimeInterval.leastNormalMagnitude...TimeInterval.greatestFiniteMagnitude)
            )
        }

        userDefaults.set(value, forKey: key)

        XCTAssertEqual(
            try userDefaults.ridi_object(forKey: key) as [Date]?,
            value
        )
    }
}
