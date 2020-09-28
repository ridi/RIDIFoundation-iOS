import Foundation

open class XMLDocument: XMLNode, XMLDocumentProtocol {
    open internal(set) override var parent: XMLNode? {
        get { return nil }
        set {}
    }

    open override var level: Int {
        return 0
    }

    open internal(set) var rootElement: XMLElement? {
        get {
            return children?.lazy.compactMap { $0 as? XMLElement }.first
        }
        set {
            self.children = self.children?.filter { !($0 is XMLElement) }

            if let newValue = newValue {
                self.addChild(newValue)
            }
        }
    }

    open internal(set) override var children: [XMLNode]? {
        get {
            return _children
        }
        set {
            super.children = newValue
        }
    }

    open internal(set) override var stringValue: String? {
        get { return nil }
        set {}
    }

    open override func nodes(forXPath xPath: String) throws -> [XMLNode] {
        guard !xPath.starts(with: "//@") else {
            return try flattendChildren?
                .flatMap { ($0 as? XMLElement)?.attributes ?? [] }
                .nodes(forXPath: String(xPath.dropFirst(3))) ?? []
        }

        guard !xPath.starts(with: "//") else {
            return try flattendChildren?.nodes(forXPath: String(xPath.dropFirst(2))) ?? []
        }

        guard !xPath.starts(with: "/") else {
            return try super.nodes(forXPath: String(xPath.dropFirst(1)))
        }

        return try super.nodes(forXPath: xPath)
    }
}

public protocol XMLDocumentProtocol {}

extension XMLDocumentProtocol {
    public init(data: Data) throws {
        let xmlParser = _XMLParser(data: data)
        xmlParser.start()

        guard let result = xmlParser.result else {
            throw CocoaError(.featureUnsupported)
        }

        switch result {
        case .success(let document):
            self = document as! Self
        case .failure(let error):
            throw error
        }
    }

    public init(xmlString string: String) throws {
        try self.init(data: string.data(using: .utf8)!)
    }
}
