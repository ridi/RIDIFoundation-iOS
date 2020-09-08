import XCTest
@testable import RIDIFoundation

extension XMLTests {
    @available(macOS 10.9, *)
    func testExcessiveSpineItemsWithFoundation() throws {
        let xmlData = try Data(
            contentsOf: URL(fileURLWithPath: #file)
                .deletingLastPathComponent()
                .appendingPathComponent("excessive-spine-items.xml")
        )

        let xmlDocument = try Foundation.XMLDocument(data: xmlData, options: [])
        let ridiXMLDocument = try RIDIFoundation.XMLDocument(data: xmlData)

        XCTAssertEqual(xmlDocument.rootElement()?.name, ridiXMLDocument.rootElement?.name)
        XCTAssertEqual(
            try xmlDocument.nodes(forXPath: "//package").first?.name,
            ridiXMLDocument[xPath: "//package"].first?.name
        )
        XCTAssertEqual(
            try xmlDocument.nodes(forXPath: "//*:title").first?.name,
            ridiXMLDocument[xPath: "//*:title"].first?.name
        )
    }
}
