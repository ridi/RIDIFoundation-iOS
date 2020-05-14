import Foundation

class XMLAttribute: XMLNode {
    override var level: Int {
        return parent?.level ?? 0
    }
}
