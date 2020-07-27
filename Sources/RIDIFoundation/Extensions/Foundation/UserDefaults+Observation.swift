// swiftlint:disable function_default_parameter_at_end
import Foundation

extension UserDefaults {
    public struct KeyValueObservedChange<Value: Codable> {
        public typealias Kind = NSKeyValueChange

        public let kind: KeyValueObservedChange<Value>.Kind

        ///newValue and oldValue will only be non-nil if .new/.old is passed to `observe()`.
        ///In general, get the most up to date value by accessing it directly on the observed object instead.
        public let newValue: Value?

        public let oldValue: Value?

        ///indexes will be nil unless the observed KeyPath refers to an ordered to-many property
        public let indexes: IndexSet?

        ///'isPrior' will be true if this change observation is being sent before the change happens,
        ///due to .prior being passed to `observe()`
        public let isPrior: Bool
    }

    public class KeyValueObservation<Value: Codable>: NSObject {
        @nonobjc private unowned let userDefaults: UserDefaults
        @nonobjc private let key: Key<Value>
        @nonobjc private var changeHandler: ((UserDefaults, KeyValueObservedChange<Value>) -> Void)?

        init(
            userDefaults: UserDefaults = .standard,
            key: Key<Value>, options: NSKeyValueObservingOptions,
            changeHandler: @escaping (UserDefaults, KeyValueObservedChange<Value>) -> Void
        ) {
            self.userDefaults = userDefaults
            self.changeHandler = changeHandler
            self.key = key
            super.init()
            userDefaults.addObserver(self, forKeyPath: key.rawValue, options: options, context: nil)
        }

        deinit {
            invalidate()
        }

        public override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            guard let change = change, object != nil, keyPath == key.rawValue else { return }
            changeHandler?(
                userDefaults,
                KeyValueObservedChange(
                    kind: NSKeyValueChange(rawValue: change[.kindKey] as! UInt)!,
                    newValue: try? change[.newKey] as? Value ?? UserDefaults.decode(change[.newKey]),
                    oldValue: try? change[.oldKey] as? Value ?? UserDefaults.decode(change[.oldKey]),
                    indexes: change[.indexesKey] as? IndexSet,
                    isPrior: change[.notificationIsPriorKey] as? Bool == true
                )
            )
        }

        public func invalidate() {
            guard changeHandler != nil else {
                return
            }

            userDefaults.removeObserver(self, forKeyPath: key.rawValue, context: nil)
            changeHandler = nil
        }
    }

    public func observe<Value>(
        _ key: Key<Value>,
        options: NSKeyValueObservingOptions = [.new],
        changeHandler: @escaping (UserDefaults, KeyValueObservedChange<Value>) -> Void
    ) -> UserDefaults.KeyValueObservation<Value> {
        KeyValueObservation<Value>(userDefaults: self, key: key, options: options, changeHandler: changeHandler)
    }
}

extension UserDefaults.Binding {
    public func observe(
        options: NSKeyValueObservingOptions = [.new],
        _ changeHandler: @escaping (UserDefaults.Binding<Value>, UserDefaults.KeyValueObservedChange<Value>) -> Void
    ) -> UserDefaults.KeyValueObservation<Value> {
        userDefaults.observe(self.key, options: options) {
            changeHandler(self, $1)
        }
    }
}
