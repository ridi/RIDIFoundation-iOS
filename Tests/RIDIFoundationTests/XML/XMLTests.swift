import XCTest
@testable import class RIDIFoundation.XMLDocument
@testable import class RIDIFoundation.XMLElement

final class XMLTests: XCTestCase {
    func testXMLInitNote() throws {
        let xmlData = try Data(contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("note.xml"))

        let xmlDocument = try XMLDocument(data: xmlData)

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

    func testXMLSubscriptByXPathNote() throws {
        let xmlData = try Data(contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("note.xml"))

        let xmlDocument = try XMLDocument(data: xmlData)

        XCTAssertEqual(xmlDocument[xPath: "/note/to"].first?.name, "to")
        XCTAssertEqual(xmlDocument[xPath: "/note/to"].first?.stringValue, "Tove")
        XCTAssertEqual(xmlDocument[xPath: "/note/body"].first?.name, "body")
        XCTAssertEqual(xmlDocument[xPath: "/note/body"].first?.stringValue, "Don't forget me this weekend!")
    }

    func testXMLInitContainer() throws {
        let xmlData = try Data(contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("container.xml"))

        let xmlDocument = try XMLDocument(data: xmlData)

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

    func testXMLSubscriptByXPathContainer() throws {
        let xmlData = try Data(contentsOf: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("container.xml"))

        let xmlDocument = try XMLDocument(data: xmlData)

        let rootfileNode = xmlDocument[xPath: "//rootfile"].first
        XCTAssertNotNil(rootfileNode)

        let rootfileElement = rootfileNode as? XMLElement
        XCTAssertNotNil(rootfileElement)

        XCTAssertEqual(rootfileElement?.name, "rootfile")
        XCTAssertEqual(rootfileElement?.attributes?["full-path"].first?.stringValue, "OEBPS/content.opf")
        XCTAssertEqual(rootfileElement?.attributes?["media-type"].first?.stringValue, "application/oebps-package+xml")
    }

    static var allTests = [
        ("testXMLInitNote", testXMLInitNote),
        ("testXMLSubscriptByXPathNote", testXMLSubscriptByXPathNote),
        ("testXMLInitContainer", testXMLInitContainer),
        ("testXMLSubscriptByXPathContainer", testXMLSubscriptByXPathContainer),
    ]
}

