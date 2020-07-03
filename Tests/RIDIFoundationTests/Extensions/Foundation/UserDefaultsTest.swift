@testable import RIDIFoundation
import XCTest

final class UserDefaultsTests: XCTestCase {
    func testBinding() {
        struct Test {
            struct Keys {
                static let test = UserDefaults.Key(UUID().uuidString, valueType: String.self)
            }

            @UserDefaults.Binding(key: Keys.test, defaultValue: "test")
            static var value: String
        }

        Test.value = UUID().uuidString

        XCTAssertEqual(
            UserDefaults.standard.string(forKey: Test.Keys.test.rawValue),
            Test.value
        )
    }

    func testBindingDefaultValue() {
        struct Test {
            struct Keys {
                static let test = UserDefaults.Key(UUID().uuidString, valueType: String.self)
            }

            @UserDefaults.Binding(key: Keys.test, defaultValue: UUID().uuidString)
            static var value: String
        }

        XCTAssertEqual(
            Test.value,
            Test.$value.defaultValue
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

    func testCodableBinding() {
        struct Foo: Codable, Equatable {
            let bar: String

            static func == (lhs: Foo, rhs: Foo) -> Bool {
                return lhs.bar == rhs.bar
            }
        }

        struct Test {
            struct Keys {
                static let test = UserDefaults.Key(UUID().uuidString, valueType: Foo.self)
            }

            @UserDefaults.CodableBinding(key: Keys.test, defaultValue: Foo(bar: "bar"))
            static var value: Foo
        }

        let value = Foo(bar: "foo")
        Test.value = value

        XCTAssertEqual(
            Test.value,
            value
        )
    }

    func testCodableBindingWithTopLevel() {
        struct Test {
            struct Keys {
                static let test = UserDefaults.Key(UUID().uuidString, valueType: Int.self)
            }

            @UserDefaults.CodableBinding(key: Keys.test, defaultValue: 0)
            static var value: Int
        }

        let value = 5
        Test.value = value

        XCTAssertEqual(
            Test.value,
            value
        )
    }

    func testObservation() {
        let key = UserDefaults.Key<String>(UUID().uuidString)
        let userDefaults = UserDefaults.standard

        let newValue = UUID().uuidString

        let expectation = XCTestExpectation(description: "Notified")
        expectation.expectedFulfillmentCount = 1

        let observation = userDefaults.observe(key) {
            XCTAssertEqual($0, userDefaults)
            XCTAssertEqual($1.newValue, newValue)

            expectation.fulfill()
        }

        userDefaults[key] = newValue

        wait(for: [expectation], timeout: 5.0)
    }

    func testObservationPrior() {
        let key = UserDefaults.Key<String>(UUID().uuidString)
        let userDefaults = UserDefaults.standard

        let newValue = UUID().uuidString

        let expectation = XCTestExpectation(description: "Notified")
        expectation.expectedFulfillmentCount = 2

        let observation = userDefaults.observe(key, options: [.prior, .new]) {
            XCTAssertEqual($0, userDefaults)
            _ = $1

            expectation.fulfill()
        }

        userDefaults[key] = newValue

        wait(for: [expectation], timeout: 5.0)
    }

    @available(macOS 10.15, iOS 13.0, *)
    func testBindingPublisher() throws {
        struct Test {
            struct Keys {
                static let test = UserDefaults.Key(UUID().uuidString, valueType: String.self)
            }

            @UserDefaults.Binding(key: Keys.test, defaultValue: "test")
            static var value: String
        }

        let expection = XCTestExpectation()
        let testValue = UUID().uuidString

        let observation = Test.$value
            .publisher
            .sink { value in
                XCTAssertEqual(value, testValue)
                expection.fulfill()
            }

        Test.value = testValue

        XCTAssertEqual(
            UserDefaults.standard.string(forKey: Test.Keys.test.rawValue),
            Test.value
        )

        wait(for: [expection], timeout: 10.0)

        observation.cancel()
    }

    static var allTests = [
        ("testBinding", testBinding),
        ("testSubscript", testSubscript),
        ("testIntSubscript", testIntSubscript),
        ("testFloatSubscript", testFloatSubscript),
        ("testDoubleSubscript", testDoubleSubscript),
        ("testBoolSubscript", testBoolSubscript),
        ("testCodable", testCodable),
        ("testCodableBinding", testCodableBinding),
        ("testCodableBindingWithTopLevel", testCodableBindingWithTopLevel),
        ("testObservation", testObservation),
        ("testObservationPrior", testObservationPrior)
    ]
}
