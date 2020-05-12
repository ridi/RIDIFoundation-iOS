import Foundation

struct XMLAttribute: _XMLNode {
    var parent: XMLNode?
    var children: [XMLNode]? {
        get { return nil }
        set {}
    }
    
    var name: String?
    var stringValue: String?
}
