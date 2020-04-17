import Foundation

extension UndoManager {
    @available(iOS 9.0, *)
    open func setValueUndoable<TargetType, ValueType>(
        withTarget target: TargetType,
        value newValue: ValueType,
        for keyPath: ReferenceWritableKeyPath<TargetType, ValueType>
    ) where TargetType: AnyObject {
        let oldValue = target[keyPath: keyPath]

        target[keyPath: keyPath] = newValue
        registerUndo(withTarget: target) { $0[keyPath: keyPath] = oldValue }
    }
}
