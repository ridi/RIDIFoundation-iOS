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

    override var _children: [XMLNode]? {
        willSet {
            precondition(newValue?.filter({ $0 is XMLElement }).count ?? 0 <= 1)
        }
    }

    open internal(set) override var stringValue: String? {
        get { return nil }
        set {}
    }

    override func nodes(forXPath xPath: String) throws -> [XMLNode] {
        guard !xPath.starts(with: "//") else {
            guard !xPath.dropFirst(2).starts(with: "@") else {
                return try flattendChildren?.flatMap { try $0.nodes(forXPath: String(xPath.dropFirst(2))) } ?? []
            }

            let paths = xPath.split(separator: "/")
            let firstPath = paths.first.flatMap { String($0) }

            let elements = flattendChildren?.filter({ $0.name == firstPath })

            if paths.dropFirst().isEmpty {
                return elements ?? []
            } else {
                return try elements?.flatMap {
                    try $0.nodes(forXPath: paths.dropFirst().joined(separator: "/"))
                } ?? []
            }
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
            throw POSIXError(.ENOSYS)
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
