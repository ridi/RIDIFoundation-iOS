import Foundation

public protocol XMLNode {
    var rootDocument: XMLDocument? { get }
    var parent: XMLNode? { get }
    var children: [XMLNode]? { get }

    var name: String? { get }
    var stringValue: String? { get }

    var xPath: String? { get }

    func nodes(forXPath xPath: String) throws -> [XMLNode]
}

extension XMLNode {
    public var rootDocument: XMLDocument? {
        return nil
    }

    public var parent: XMLNode? {
        return nil
    }

    public var children: [XMLNode]? {
        return nil
    }

    public var name: String? {
        return nil
    }

    public var stringValue: String? {
        return nil
    }

    public var xPath: String? {
        return nil
    }

    // FIXME: Only support elements selection
    public func nodes(forXPath xPath: String) throws -> [XMLNode] {
        guard !xPath.starts(with: "/") || (self is XMLDocument) else {
            return try rootDocument?.nodes(forXPath: String(xPath.dropFirst(1))) ?? []
        }

        guard !xPath.starts(with: "../") else {
            return try parent?.nodes(forXPath: String(xPath.dropFirst(3))) ?? []
        }

        let paths = xPath.split(separator: "/")
        let firstPath = paths.first.flatMap { String($0) }

        guard let elements = children?.compactMap({ $0 as? XMLElement }).filter({ $0.name == firstPath }) else {
            return []
        }

        if paths.dropFirst().count == 0 {
            return elements
        } else {
            return try elements.flatMap {
                try $0.nodes(forXPath: paths.dropFirst().joined(separator: "/"))
            }
        }
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
