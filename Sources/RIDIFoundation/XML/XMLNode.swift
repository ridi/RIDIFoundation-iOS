import Foundation

open class XMLNode: CustomDebugStringConvertible {
    open var rootDocument: XMLDocument? {
        return parent?.rootDocument ?? (parent as? XMLDocument)
    }

    open internal(set) weak var parent: XMLNode?

    lazy var _children: [XMLNode] = []
    open internal(set) var children: [XMLNode]? {
        get {
            return nil
        }
        set {
            let oldValue = _children

            newValue?.forEach { $0.parent = self }

            _children = newValue ?? []

            oldValue.forEach { $0.parent = nil }
        }
    }

    open internal(set) var name: String?
    open internal(set) var stringValue: String?

    open var level: Int {
        if let parent = parent, 
            parent !== rootDocument {
                return parent.level + 1
        } else {
            return 0
        }
    }

    open var xPath: String? {
        return nil
    }

    var _parserContext: _XMLParserContext?

    var objectDescription: String {
        return "\(String(reflecting: Self.self)): \(Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque())"
    }

    public var debugDescription: String {
        let descriptions = [
            objectDescription,
            name.flatMap { "name: \($0)" },
            stringValue.flatMap { "value: \($0)" },
            (rootDocument?.objectDescription).flatMap { "rootDocument: \($0)" },
            (parent?.objectDescription).flatMap { "parent: \($0)" },
            "children: \(_children)",
            "level: \(level)",
            xPath.flatMap { "xPath: \($0)" },
            (_parserContext?.publicID).flatMap { "publicID: \($0)" },
            (_parserContext?.systemID).flatMap { "systemID: \($0)" },
            (_parserContext?.lineNumber).flatMap { "lineNumber: \($0)" },
            (_parserContext?.columnNumber).flatMap { "columnNumber: \($0)" }
        ].compactMap { $0 }.joined(separator: "; ")

        return "<\(descriptions)>"
    }

    required public init() {}

    required public init(_ xmlNode: XMLNode) {
        self.parent = xmlNode.parent

        self.name = xmlNode.name
        self.stringValue = xmlNode.stringValue
    }

    // FIXME: Not support predicate yet!
    open func nodes(forXPath xPath: String) throws -> [XMLNode] {
        guard !xPath.starts(with: "/") else {
            return try rootDocument?.nodes(forXPath: xPath) ?? []
        }

        guard !xPath.starts(with: "../") else {
            return try parent?.nodes(forXPath: String(xPath.dropFirst(3))) ?? []
        }

        let paths = xPath.split(separator: "/")
        guard
            let firstPath = paths.first.flatMap({ String($0) })?.split(separator: ":"),
            (1...2) ~= firstPath.count
        else {
            throw XMLError.invalidXPath
        }

        let elements = children?.filter {
            switch firstPath.count {
            case 2 where firstPath[0] == "*":
                return $0.name?.split(separator: ":").last == firstPath[1]
            default:
                return $0.name == firstPath.joined(separator: ":")
            }
        }

        if paths.dropFirst().isEmpty {
            return elements ?? []
        } else {
            return try elements?.flatMap {
                try $0.nodes(forXPath: paths.dropFirst().joined(separator: "/"))
            } ?? []
        }
    }

    func insertChild(_ child: XMLNode, at index: Int) {
        child.parent = self

        _children.insert(child, at: index)
    }

    func insertChildren(_ children: [XMLNode], at index: Int) {
        children.forEach { $0.parent = self }

        _children.insert(contentsOf: children, at: index)
    }

    func removeChild(at index: Int) {
        let child = _children.remove(at: index)

        child.parent = nil
    }

    func addChild(_ child: XMLNode) {
        child.parent = self

        _children.append(child)
    }
}

extension XMLNode {
    subscript(indexPath: IndexPath) -> XMLNode? {
        get {
            var indexPath = indexPath

            guard let index = indexPath.popFirst() else {
                return self
            }

            guard let children = children else {
                return nil
            }

            guard index < children.count else {
                return nil
            }

            if indexPath.isEmpty {
                return children[index]
            } else {
                return children[index][indexPath]
            }
        }
        set {
            var indexPath = indexPath

            guard let index = indexPath.popFirst() else {
                fatalError("Array index out of range")
            }

            if indexPath.isEmpty {
                if let newValue = newValue {
                    if index == (children?.count ?? 0) {
                        addChild(newValue)
                    } else {
                        insertChild(newValue, at: index)
                    }
                } else {
                    removeChild(at: index)
                }
            } else {
                children![index][indexPath] = newValue
            }
        }
    }

    var flattendChildren: [XMLNode]? {
        guard let children = children else {
            return nil
        }

        return children.flatMap { [$0] + ($0.flattendChildren ?? []) }
    }
}

extension XMLNode {
    public subscript(xPath xPath: String) -> [XMLNode] {
        try! nodes(forXPath: xPath)
    }
}

extension XMLNode {
    public subscript(name: String) -> [XMLNode] {
        return children?.filter { $0.name == name } ?? []
    }
}

extension Array where Element == XMLNode {
    public subscript(name: String) -> [XMLNode] {
        return filter { $0.name == name }
    }
}
