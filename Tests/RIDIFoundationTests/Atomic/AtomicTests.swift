@testable import RIDIFoundation
import XCTest

final class AtomicTests: XCTestCase {
    func testUpdate() throws {
        struct Test {
            @Atomic
            static var value: Int = .random(in: (.min)...(.max))
        }

        let newValue = Int.random(in: (.min)...(.max))

        Test.value = newValue
        XCTAssertEqual(Test.value, newValue)
    }

    func testConcurrentPerform() throws {
        struct Test {
            @Atomic
            static var value: Int = .random(in: (.min)...(.max))
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

    func testOnQueueAsBarrier() throws {
        struct Test {
            static var queue = DispatchQueue(label: "test")

            @Atomic(queue: queue)
            static var value: Int = .random(in: (.min)...(.max))
        }

        let expectaion = XCTestExpectation()

        Test.$value.perform { _ in
            dispatchPrecondition(condition: .onQueueAsBarrier(Test.queue))
            expectaion.fulfill()
        }

        wait(for: [expectaion], timeout: 10.0)
    }
}
