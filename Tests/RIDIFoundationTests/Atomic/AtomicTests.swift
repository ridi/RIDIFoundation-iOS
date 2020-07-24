@testable import RIDIFoundation
import XCTest

final class AtomicTests: XCTestCase {
    func testConcurrentPerform() throws {
        struct Test {
            @Atomic
            static var value: Int = -1
        }

        let expectaion = XCTestExpectation()
        expectaion.assertForOverFulfill = true
        expectaion.expectedFulfillmentCount = 1000

        DispatchQueue.concurrentPerform(iterations: 1000) { i in
            Test.$value.perform {
                $0 = i
                XCTAssertEqual($0, i)
                expectaion.fulfill()
            }
            XCTAssertTrue(0..<1000 ~= Test.value)
        }

        wait(for: [expectaion], timeout: 10.0)

        XCTAssertEqual(Test.value, 999)
    }
}
