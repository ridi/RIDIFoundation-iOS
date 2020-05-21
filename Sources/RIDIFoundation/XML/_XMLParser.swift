import Foundation

class _XMLParser: Operation {
    private var xmlParser: XMLParser

    var result: Result<XMLDocument, Error>?

    private lazy var xmlDocument = XMLDocument()
    private lazy var xmlDocumentCurrentIndexPath = IndexPath()

    private var isNodeOpened: Bool = false

    init(data: Data) {
        xmlParser = .init(data: data)
        super.init()

        xmlParser.delegate = self
    }

    override func main() {
        result = nil
        xmlParser.parse()
        result = result ?? xmlParser.parserError.flatMap { .failure($0) }
    }
}

extension _XMLParser: XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) {
        xmlDocument = XMLDocument()
        xmlDocumentCurrentIndexPath = IndexPath()
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        result = .failure(parseError)
    }

    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        result = .failure(validationError)
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        result = .success(xmlDocument)
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        let newElement = XMLElement()
        newElement.name = elementName
        newElement.attributes = attributeDict.map {
            let attribute = XMLAttribute()
            attribute.name = $0.key
            attribute.stringValue = $0.value

            return attribute
        }
        newElement._parserContext = .init(
            publicID: parser.publicID,
            systemID: parser.systemID,
            lineNumber: parser.lineNumber,
            columnNumber: parser.columnNumber
        )

        isNodeOpened = true

        guard !xmlDocumentCurrentIndexPath.isEmpty else {
            xmlDocument.addChild(newElement)
            xmlDocumentCurrentIndexPath.append(xmlDocument.children!.endIndex - 1)
            return
        }

        xmlDocument[xmlDocumentCurrentIndexPath]!.addChild(newElement)
        xmlDocumentCurrentIndexPath.append((xmlDocument[xmlDocumentCurrentIndexPath]?.children?.endIndex ?? 1) - 1)
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        isNodeOpened = false

        var parentElementIndexPath = xmlDocumentCurrentIndexPath
        repeat {
            guard xmlDocument[xmlDocumentCurrentIndexPath]?.name == elementName else {
                parentElementIndexPath.removeLast()
                continue
            }

            xmlDocumentCurrentIndexPath.removeLast(xmlDocumentCurrentIndexPath.count - parentElementIndexPath.count + 1)
            break
        } while (!parentElementIndexPath.isEmpty)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard
            let currentNode = xmlDocument[xmlDocumentCurrentIndexPath],
            isNodeOpened
        else {
            return
        }

        if currentNode.stringValue != nil {
            currentNode.stringValue!.append(string)
        } else {
            currentNode.stringValue = string
        }
    }
}
