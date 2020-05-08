import Foundation

public class XMLDocument: XMLDocumentProtocol, _XMLNode {
    private var _children: [XMLNode] = [] {
        willSet {
            precondition(newValue.filter({ $0 is XMLElement }).count <= 1)
        }
    }

    public internal(set) var children: [XMLNode]? {
        get {
            return _children
        }
        set {
            _children = newValue ?? []
        }
    }

    public internal(set) var rootElement: XMLElement? {
        get {
            return children?.lazy.compactMap { $0 as? XMLElement }.first
        }
        set {
            children?.removeAll(where: { $0 is XMLElement })

            if let newValue = newValue {
                if children != nil {
                    children!.append(newValue)
                } else {
                    children = [newValue]
                }
            }
        }
    }

    init() {

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
