import Foundation

open class XMLNode {
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

    var xPath: String? {
        return nil
    }

    required public init() {}

    required public init(_ xmlNode: XMLNode) {
        self.parent = xmlNode.parent

        self.name = xmlNode.name
        self.stringValue = xmlNode.stringValue
    }

    // FIXME: Not support predicate yet!
    func nodes(forXPath xPath: String) throws -> [XMLNode] {
        guard !xPath.starts(with: "/") else {
            return try rootDocument?.nodes(forXPath: xPath) ?? []
        }

        guard !xPath.starts(with: "../") else {
            return try parent?.nodes(forXPath: String(xPath.dropFirst(3))) ?? []
        }

        let paths = xPath.split(separator: "/")
        let firstPath = paths.first.flatMap { String($0) }

        let elements = children?.filter({ $0.name == firstPath })

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
                fatalError()
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
