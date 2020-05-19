import XCTest
@testable import class RIDIFoundation.XMLDocument
@testable import class RIDIFoundation.XMLElement

final class XMLTests: XCTestCase {
    func testXMLInitNote() throws {
        let xmlData = try Data(
            contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("note.xml")
        )

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            startMeasuring()
            let xmlDocument = try! XMLDocument(data: xmlData)
            stopMeasuring()

            XCTAssertEqual(xmlDocument.children?.count, 1)
            XCTAssertEqual(xmlDocument.children?[0].name, "note")
            XCTAssertEqual(xmlDocument.children?[0].children?.count, 4)
            XCTAssertEqual(xmlDocument.children?[0].children?[0].name, "to")
            XCTAssertEqual(xmlDocument.children?[0].children?[0].stringValue, "Tove")
            XCTAssertEqual(xmlDocument.children?[0].children?[1].name, "from")
            XCTAssertEqual(xmlDocument.children?[0].children?[1].stringValue, "Jani")
            XCTAssertEqual(xmlDocument.children?[0].children?[2].name, "heading")
            XCTAssertEqual(xmlDocument.children?[0].children?[2].stringValue, "Reminder")
            XCTAssertEqual(xmlDocument.children?[0].children?[3].name, "body")
            XCTAssertEqual(xmlDocument.children?[0].children?[3].stringValue, "Don't forget me this weekend!")
        }
    }

    func testXMLSubscriptByXPathNote() throws {
        let xmlData = try Data(
            contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("note.xml")
        )

        let xmlDocument = try XMLDocument(data: xmlData)

        let toElements = xmlDocument[xPath: "//to"]
        XCTAssertEqual(toElements.count, 1)
        XCTAssertEqual(toElements.first?.name, "to")
        XCTAssertEqual(toElements.first?.stringValue, "Tove")
        XCTAssertEqual(toElements.first?.xPath, "/note/to")
        XCTAssert(toElements.first?.rootDocument === xmlDocument)

        let noteBodyElements = xmlDocument[xPath: "/note/body"]
        XCTAssertEqual(noteBodyElements.count, 1)
        XCTAssertEqual(noteBodyElements.first?.name, "body")
        XCTAssertEqual(noteBodyElements.first?.stringValue, "Don't forget me this weekend!")
        XCTAssertEqual(noteBodyElements.first?.xPath, "/note/body")
        XCTAssert(noteBodyElements.first?.rootDocument === xmlDocument)
    }

    func testXMLInitContainer() throws {
        let xmlData = try Data(
            contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("container.xml")
        )

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            startMeasuring()
            let xmlDocument = try! XMLDocument(data: xmlData)
            stopMeasuring()

            XCTAssertEqual(xmlDocument.children?.count, 1)

            let containerElement = xmlDocument.children?[0] as? RIDIFoundation.XMLElement
            XCTAssertEqual(containerElement?.name, "container")
            XCTAssertEqual(containerElement?.attributes?["xmlns"].first?.stringValue, "urn:oasis:names:tc:opendocument:xmlns:container")
            XCTAssertEqual(containerElement?.attributes?["version"].first?.stringValue, "1.0")
            XCTAssertEqual(containerElement?.children?.count, 1)

            let rootfilesElement = containerElement?.children?[0] as? XMLElement
            XCTAssertEqual(rootfilesElement?.name, "rootfiles")
            XCTAssertEqual(rootfilesElement?.attributes?.count, 0)
            XCTAssertEqual(rootfilesElement?.children?.count, 1)

            let rootfileElement = rootfilesElement?.children?[0] as? XMLElement
            XCTAssertEqual(rootfileElement?.name, "rootfile")
            XCTAssertEqual(rootfileElement?.attributes?["full-path"].first?.stringValue, "OEBPS/content.opf")
            XCTAssertEqual(rootfileElement?.attributes?["media-type"].first?.stringValue, "application/oebps-package+xml")
        }
    }

    func testXMLSubscriptByXPathContainer() throws {
        let xmlData = try Data(
            contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("container.xml")
        )

        let xmlDocument = try XMLDocument(data: xmlData)
        XCTAssertNotNil(xmlDocument.rootElement)
        XCTAssertEqual(xmlDocument.level, 0)

        let xmlnsNodes = xmlDocument[xPath: "//@xmlns"]
        XCTAssertEqual(xmlnsNodes.count, 1)
        XCTAssertEqual(xmlnsNodes.first?.stringValue, "urn:oasis:names:tc:opendocument:xmlns:container")
        XCTAssertEqual(xmlnsNodes.first?.level, 0)

        let rootfileNodes = xmlDocument[xPath: "//rootfile"]
        XCTAssertEqual(rootfileNodes.count, 1)

        let rootfileElement = rootfileNodes.first as? XMLElement
        XCTAssertNotNil(rootfileElement)
        XCTAssertEqual(rootfileElement?.name, "rootfile")
        XCTAssertEqual(rootfileElement?.level, 2)
        XCTAssertEqual(rootfileElement?.attributes?["full-path"].first?.stringValue, "OEBPS/content.opf")
        XCTAssertEqual(rootfileElement?.attributes?["media-type"].first?.stringValue, "application/oebps-package+xml")
    }

    func testExcessiveSpineItemsXMLInit() throws {
        let xmlData = try Data(
            contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("excessive-spine-items.xml")
        )

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            startMeasuring()
            let xmlDocument = try! XMLDocument(data: xmlData)
            stopMeasuring()

            XCTAssertEqual(xmlDocument.children?.count, 1)
        }
    }

    func testDeepDepthNavipointsXMLInit() throws {
        let xmlData = try Data(
            contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("deep-depth-navipoints.xml")
        )

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            startMeasuring()
            let xmlDocument = try! XMLDocument(data: xmlData)
            stopMeasuring()

            XCTAssertEqual(xmlDocument.children?.count, 1)
        }
    }

    func testExcessiveNavpointsXMLInit() throws {
        let xmlData = try Data(
            contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("excessive-navpoints.xml")
        )

        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            startMeasuring()
            let xmlDocument = try! XMLDocument(data: xmlData)
            stopMeasuring()

            XCTAssertEqual(xmlDocument.children?.count, 1)
        }
    }

    static var allTests = [
        ("testXMLInitNote", testXMLInitNote),
        ("testXMLSubscriptByXPathNote", testXMLSubscriptByXPathNote),
        ("testXMLInitContainer", testXMLInitContainer),
        ("testXMLSubscriptByXPathContainer", testXMLSubscriptByXPathContainer),
    ]
}

