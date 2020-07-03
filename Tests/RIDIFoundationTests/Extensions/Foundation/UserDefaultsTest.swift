@testable import RIDIFoundation
import XCTest

final class UserDefaultsTests: XCTestCase {
    var userDefaults: UserDefaults{
        .standard
    }

    override func tearDown() {
        super.tearDown()

        userDefaults.dictionaryRepresentation().forEach { key, _ in
            userDefaults.removeObject(forKey: key)
        }
    }

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

    func testBindingNil() {
        struct Test {
            struct Keys {
                static let test = UserDefaults.Key(UUID().uuidString, valueType: String?.self)
            }

            @UserDefaults.Binding(key: Keys.test, defaultValue: "test")
            static var value: String?
        }

        Test.value = nil

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

    func testBindingCodable() {
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

            @UserDefaults.Binding(key: Keys.test, defaultValue: Foo(bar: "bar"))
            static var value: Foo
        }

        let value = Foo(bar: "foo")
        Test.value = value

        XCTAssertEqual(
            Test.value,
            value
        )
    }

    func testBindingCodableWithTopLevel() {
        struct Test {
            struct Keys {
                static let test = UserDefaults.Key(UUID().uuidString, valueType: Int.self)
            }

            @UserDefaults.Binding(key: Keys.test, defaultValue: 0)
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
        ("testIntSubscript", testIntSubscript),
        ("testFloatSubscript", testFloatSubscript),
        ("testDoubleSubscript", testDoubleSubscript),
        ("testBoolSubscript", testBoolSubscript),
        ("testBindingCodable", testBindingCodable),
        ("testBindingCodableWithTopLevel", testBindingCodableWithTopLevel),
        ("testObservation", testObservation),
        ("testObservationPrior", testObservationPrior)
    ]
}
