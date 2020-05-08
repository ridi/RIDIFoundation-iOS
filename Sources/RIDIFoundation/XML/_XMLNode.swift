import Foundation

protocol _XMLNode: XMLNode {
    var children: [XMLNode]? { get set }
}

extension _XMLNode {
    public subscript(indexPath: IndexPath) -> _XMLNode? {
        get {
            var indexPath = indexPath

            guard let index = indexPath.popFirst() else {
                return self
            }

            guard let children = children?.compactMap({ $0 as? _XMLNode }) else {
                return nil
            }

            guard index < children.count else {
                return nil
            }

            if indexPath.count > 0 {
                return children[index][indexPath]
            } else {
                return children[index]
            }
        }
        set {
            var indexPath = indexPath

            var children = self.children ?? []

            guard let index = indexPath.popFirst() else {
                fatalError()
            }

            if indexPath.count > 0 {
                guard var child = children[index] as? _XMLNode else {
                    fatalError()
                }
                child[indexPath] = newValue
                children[index] = child
                self.children = children
            } else {
                if let newValue = newValue {
                    if index == children.count {
                        children.append(newValue)
                    } else {
                        children[index] = newValue
                    }
                } else {
                    children.remove(at: index)
                }

                self.children = children
            }
        }
    }
}
