@testable import RIDIFoundation
import XCTest

extension UserDefaultsTests {
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

    func testObservationCodable() throws {
        let key = UserDefaults.Key<UUID>(UUID().uuidString)
        let userDefaults = UserDefaults.standard

        let newValue = UUID()

        let expectation = XCTestExpectation(description: "Notified")
        expectation.expectedFulfillmentCount = 1

        let observation = userDefaults.observe(key) {
            XCTAssertEqual($0, userDefaults)
            XCTAssertEqual($1.newValue, newValue)

            expectation.fulfill()
        }

        try userDefaults.ridi_set(newValue, forKey: key)

        wait(for: [expectation], timeout: 5.0)
    }
}
