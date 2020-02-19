//
//  UserDefaultsTest.swift
//
//

@testable import RIDIFoundation
import XCTest

final class UserDefaultsTests: XCTestCase {
    func testBinding() {
        struct Test {
            struct Keys {
                static let test = UserDefaults.Key<String>(UUID().uuidString)
            }

            @UserDefaults .Binding(key: Keys.test, defaultValue: "test")
            static var value: String
        }

        Test.value = UUID().uuidString

        XCTAssertEqual(
            UserDefaults.standard.string(forKey: Test.Keys.test.rawValue),
            Test.value
        )
    }

    func testSubscript() {
        let key = UserDefaults.Key<Any>(UUID().uuidString)

        UserDefaults.standard[key] = UUID().uuidString as NSString

        XCTAssertEqual(
            UserDefaults.standard[key] as? NSString,
            UserDefaults.standard.object(forKey: key.rawValue) as? NSString
        )
    }

    func testIntSubscript() {
        let key = UserDefaults.Key<Int>(UUID().uuidString)

        UserDefaults.standard[key] = .random(in: Int.min...Int.max)

        XCTAssertEqual(
            UserDefaults.standard[key],
            UserDefaults.standard.integer(forKey: key.rawValue)
        )
    }

    func testFloatSubscript() {
        let key = UserDefaults.Key<Float>(UUID().uuidString)

        UserDefaults.standard[key] = .random(in: Float.leastNormalMagnitude...Float.greatestFiniteMagnitude)

        XCTAssertEqual(
            UserDefaults.standard[key],
            UserDefaults.standard.float(forKey: key.rawValue)
        )
    }

    func testDoubleSubscript() {
        let key = UserDefaults.Key<Double>(UUID().uuidString)

        UserDefaults.standard[key] = .random(in: Double.leastNormalMagnitude...Double.greatestFiniteMagnitude)

        XCTAssertEqual(
            UserDefaults.standard[key],
            UserDefaults.standard.double(forKey: key.rawValue)
        )
    }

    func testBoolSubscript() {
        let key = UserDefaults.Key<Bool>(UUID().uuidString)

        UserDefaults.standard[key] = .random()

        XCTAssertEqual(
            UserDefaults.standard[key],
            UserDefaults.standard.bool(forKey: key.rawValue)
        )
    }

    func testCodable() throws {
        struct Test: Codable, Equatable {
            var a = UUID()
            var b = URL(fileURLWithPath: "/")
        }

        let key = UserDefaults.Key<Test>(UUID().uuidString)
        let value = Test()

        try UserDefaults.standard.set(value, forKey: key)

        XCTAssertEqual(
            try UserDefaults.standard.object(forKey: key),
            value
        )
    }

    static var allTests = [
        ("testBinding", testBinding),
        ("testSubscript", testSubscript),
        ("testIntSubscript", testIntSubscript),
        ("testFloatSubscript", testFloatSubscript),
        ("testDoubleSubscript", testDoubleSubscript),
        ("testBoolSubscript", testBoolSubscript),
        ("testCodable", testCodable)
    ]
}
