import Foundation

open class XMLElement: XMLNode {
    open internal(set) override var children: [XMLNode]? {
        get {
            return _children
        }
        set {
            super.children = newValue
        }
    }

    open internal(set) var attributes: [XMLNode]? {
        willSet {
            attributes?.forEach {
                $0.parent = nil
            }
        }
        didSet {
            attributes?.forEach {
                $0.parent = self
            }
        }
    }

    open override var xPath: String? {
        return name.flatMap { name in
            parent.flatMap { parent in
                (parent.xPath ?? "") + "/" + name
            }
        }
    }

    public override var debugDescription: String {
        let descriptions = [
            objectDescription,
            name.flatMap { "name: \($0)" },
            stringValue.flatMap { "value: \($0)" },
            (rootDocument?.objectDescription).flatMap { "rootDocument: \($0)" },
            (parent?.objectDescription).flatMap { "parent: \($0)" },
            "children: \(_children)",
            attributes.flatMap { "attributes: \($0)" },
            "level: \(level)",
            xPath.flatMap { "xPath: \($0)" },
            (_parserContext?.publicID).flatMap { "publicID: \($0)" },
            (_parserContext?.systemID).flatMap { "systemID: \($0)" },
            (_parserContext?.lineNumber).flatMap { "lineNumber: \($0)" },
            (_parserContext?.columnNumber).flatMap { "columnNumber: \($0)" }
        ].compactMap { $0 }.joined(separator: "; ")

        return "<\(descriptions)>"
    }

    open override func nodes(forXPath xPath: String) throws -> [XMLNode] {
        guard !xPath.starts(with: "@") else {
            let paths = xPath.split(separator: "/")
            let firstPath = paths.first.flatMap { String($0.dropFirst(1)) }

            let attributes = self.attributes?.filter({ $0.name == firstPath })

            if paths.dropFirst().isEmpty {
                return attributes ?? []
            } else {
                return try attributes?.flatMap {
                    try $0.nodes(forXPath: paths.dropFirst().joined(separator: "/"))
                } ?? []
            }
        }

        return try super.nodes(forXPath: xPath)
    }

    open func attribute(forName name: String) -> XMLNode? {
        attributes?.first(where: { $0.name == name })
    }
}
