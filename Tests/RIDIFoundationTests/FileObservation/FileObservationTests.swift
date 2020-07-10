@testable import RIDIFoundation
import XCTest

final class FileObservationTests: XCTestCase {
    func test() throws {
        let tempDirectory = URL(
            fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString, isDirectory: true)

        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        let expectation = XCTestExpectation(description: "Notified")
        expectation.expectedFulfillmentCount = 1

        var fileObservation: FileObservation? = try FileObservation.observe(at: tempDirectory) {
            expectation.fulfill()
        }

        try "".write(
            to: tempDirectory.appendingPathComponent(UUID().uuidString),
            atomically: true,
            encoding: .utf8
        )

        fileObservation = nil

        try FileManager.default.removeItem(at: tempDirectory)

        wait(for: [expectation], timeout: 5.0)
    }

    func testNilNotify() throws {
        let tempDirectory = URL(
            fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString, isDirectory: true)

        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        let expectation = XCTestExpectation(description: "Notified")
        expectation.isInverted = true

        var fileObservation: FileObservation? = try FileObservation.observe(at: tempDirectory) {
            expectation.fulfill()
        }

        fileObservation = nil

        try FileManager.default.removeItem(at: tempDirectory)

        wait(for: [expectation], timeout: 5.0)
    }
}
