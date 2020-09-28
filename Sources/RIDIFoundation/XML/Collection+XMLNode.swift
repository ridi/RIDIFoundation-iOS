import Foundation

extension Collection where Element: XMLNode {
    func nodes(forXPath xPath: String) throws -> [XMLNode] {
        let paths = xPath.split(separator: "/")
        guard
            let firstPath = paths.first.flatMap({ String($0) })?.split(separator: ":"),
            (1...2) ~= firstPath.count
        else {
            throw XMLError.invalidXPath
        }

        let elements = filter {
            switch firstPath.count {
            case 2 where firstPath[0] == "*":
                return $0.name?.split(separator: ":").last == firstPath[1]
            default:
                return $0.name == firstPath.joined(separator: ":")
            }
        }

        if paths.dropFirst().isEmpty {
            return elements
        } else {
            return try elements.flatMap {
                try $0.nodes(forXPath: paths.dropFirst().joined(separator: "/"))
            }
        }
    }
}
