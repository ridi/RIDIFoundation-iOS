import Foundation

public class XMLElement: _XMLNode {
    public internal(set) var rootDocument: XMLDocument?
    public internal(set) var parent: XMLNode?
    private var _children: [XMLNode] = []
    public internal(set) var children: [XMLNode]? {
        get {
            return _children
        }
        set {
            _children = newValue ?? []
        }
    }


    public internal(set) var name: String?
    public internal(set) var stringValue: String?
    public internal(set) var attributes: [XMLNode]?
}
