@testable import RIDIFoundation
import XCTest

extension UserDefaultsTests {
    func testObservation() {
        #if swift(>=5.3)
        let key = UserDefaults.Key<String?>(UUID().uuidString)
        #else
        let key = UserDefaults.Key<String?>(UUID().uuidString, defaultValue: nil)
        #endif
        let userDefaults = UserDefaults.standard

        let newValue = UUID().uuidString

        let expectation = XCTestExpectation(description: "Notified")
        expectation.expectedFulfillmentCount = 1

        var observation: Any? = userDefaults.observe(key) {
            XCTAssertEqual($0, userDefaults)
            XCTAssertEqual($1.newValue, newValue)

            expectation.fulfill()
        }

        userDefaults[key] = newValue

        wait(for: [expectation], timeout: 5.0)

        observation = nil
        XCTAssert(observation == nil)
    }

    func testObservationPrior() {
        #if swift(>=5.3)
        let key = UserDefaults.Key<String?>(UUID().uuidString)
        #else
        let key = UserDefaults.Key<String?>(UUID().uuidString, defaultValue: nil)
        #endif
        let userDefaults = UserDefaults.standard

        let newValue = UUID().uuidString

        let expectation = XCTestExpectation(description: "Notified")
        expectation.expectedFulfillmentCount = 2

        var observation: Any? = userDefaults.observe(key, options: [.prior, .new]) {
            XCTAssertEqual($0, userDefaults)
            _ = $1

            expectation.fulfill()
        }

        userDefaults[key] = newValue

        wait(for: [expectation], timeout: 5.0)

        observation = nil
        XCTAssert(observation == nil)
    }

    func testObservationCodable() throws {
        #if swift(>=5.3)
        let key = UserDefaults.Key<UUID?>(UUID().uuidString)
        #else
        let key = UserDefaults.Key<UUID?>(UUID().uuidString, defaultValue: nil)
        #endif
        let userDefaults = UserDefaults.standard

        let newValue = UUID()

        let expectation = XCTestExpectation(description: "Notified")
        expectation.expectedFulfillmentCount = 1

        var observation: Any? = userDefaults.observe(key) {
            XCTAssertEqual($0, userDefaults)
            XCTAssertEqual($1.newValue, newValue)

            expectation.fulfill()
        }

        try userDefaults.ridi_set(newValue, forKey: key)

        wait(for: [expectation], timeout: 5.0)

        observation = nil
        XCTAssert(observation == nil)
    }

    func testObservationNil() {
        #if swift(>=5.3)
        let key = UserDefaults.Key<String?>(UUID().uuidString)
        #else
        let key = UserDefaults.Key<String?>(UUID().uuidString, defaultValue: nil)
        #endif
        let userDefaults = UserDefaults.standard

        let newValue = UUID().uuidString

        let expectation = XCTestExpectation(description: "Notified")
        expectation.isInverted = true

        var observation: Any? = userDefaults.observe(key) {
            XCTAssertEqual($0, userDefaults)
            XCTAssertEqual($1.newValue, newValue)

            expectation.fulfill()
        }

        observation = nil
        XCTAssert(observation == nil)

        userDefaults[key] = newValue

        wait(for: [expectation], timeout: 5.0)
    }

    func testObservationInvalidate() {
        #if swift(>=5.3)
        let key = UserDefaults.Key<String?>(UUID().uuidString)
        #else
        let key = UserDefaults.Key<String?>(UUID().uuidString, defaultValue: nil)
        #endif
        let userDefaults = UserDefaults.standard

        let newValue = UUID().uuidString

        let expectation = XCTestExpectation(description: "Notified")
        expectation.isInverted = true

        let observation = userDefaults.observe(key) {
            XCTAssertEqual($0, userDefaults)
            XCTAssertEqual($1.newValue, newValue)

            expectation.fulfill()
        }

        observation.invalidate()

        userDefaults[key] = newValue

        wait(for: [expectation], timeout: 5.0)
    }

    func testObservationInvalidateTwice() {
        #if swift(>=5.3)
        let key = UserDefaults.Key<String?>(UUID().uuidString)
        #else
        let key = UserDefaults.Key<String?>(UUID().uuidString, defaultValue: nil)
        #endif
        let userDefaults = UserDefaults.standard

        let newValue = UUID().uuidString

        let expectation = XCTestExpectation(description: "Notified")
        expectation.isInverted = true

        let observation = userDefaults.observe(key) {
            XCTAssertEqual($0, userDefaults)
            XCTAssertEqual($1.newValue, newValue)

            expectation.fulfill()
        }

        observation.invalidate()
        observation.invalidate()

        userDefaults[key] = newValue

        wait(for: [expectation], timeout: 5.0)
    }
}
