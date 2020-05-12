import Foundation

class _XMLParser: Operation {
    var xmlParser: Foundation.XMLParser

    public var result: Result<XMLDocument, Error>?

    private var xmlDocument: XMLDocument?
    private var xmlDocumentCurrentIndexPath = IndexPath()

    private var currentElement: XMLElement?

    public init(data: Data) {
        xmlParser = .init(data: data)
        super.init()

        xmlParser.delegate = self
    }

    override open func main() {
        xmlParser.parse()
    }
}

extension _XMLParser: XMLParserDelegate {
    func parserDidStartDocument(_ parser: XMLParser) {
        xmlDocument = XMLDocument()
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        result = .failure(parseError)
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        result = .success(xmlDocument!)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        guard let xmlDocument = xmlDocument else {
            return
        }

        let newElement = XMLElement()
        newElement.name = elementName
        newElement.attributes = attributeDict.map {
            XMLAttribute(
                name: $0.key,
                stringValue: $0.value
            )
        }

        currentElement = newElement

        guard !xmlDocumentCurrentIndexPath.isEmpty else {
            xmlDocument.children!.append(newElement)
            xmlDocumentCurrentIndexPath.append(xmlDocument.children!.endIndex - 1)
            return
        }

        var lastElement = xmlDocument[xmlDocumentCurrentIndexPath]
        lastElement?.children?.append(newElement)
        xmlDocumentCurrentIndexPath.append((xmlDocument[xmlDocumentCurrentIndexPath]?.children?.endIndex ?? 1) - 1)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let xmlDocument = xmlDocument else {
            return
        }

        currentElement = nil

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
            xmlDocument?[xmlDocumentCurrentIndexPath] != nil,
            let currentElement = currentElement
        else {
            return
        }

        currentElement.stringValue = string
    }
}
