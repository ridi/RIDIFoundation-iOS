import Foundation

struct XMLAttribute: XMLNode {
    var rootDocument: XMLDocument?
    var parent: XMLNode?
    
    var name: String?
    var stringValue: String?
}
