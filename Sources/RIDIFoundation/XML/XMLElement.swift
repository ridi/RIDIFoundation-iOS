import Foundation

public class XMLElement: XMLNode {
    public internal(set) var attributes: [XMLNode]? {
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

    public override var xPath: String? {
        return name.flatMap { name in
            parent.flatMap { parent in
                (parent.xPath ?? "") + "/" + name
            }
        }
    }

    override func nodes(forXPath xPath: String) throws -> [XMLNode] {
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

    public func attribute(forName name: String) -> XMLNode? {
        attributes?.first(where: { $0.name == name })
    }
}
