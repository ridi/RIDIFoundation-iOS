import Foundation

public class XMLElement: _XMLNode {
    public internal(set) var parent: XMLNode?
    private var _children: [XMLNode] = []
    public internal(set) var children: [XMLNode]? {
        get {
            return _children
        }
        set {
            let newValue = newValue ?? []

            _children = newValue.map {
                var node = $0 as? _XMLNode
                node?.parent = self

                return node ?? $0
            }
        }
    }

    public internal(set) var name: String?
    public internal(set) var stringValue: String?
    public internal(set) var attributes: [XMLNode]?

    public var xPath: String? {
        return name.flatMap { name in
            parent.flatMap { parent in
                (parent.xPath ?? "") + "/" + name
            }
        }
    }
}
