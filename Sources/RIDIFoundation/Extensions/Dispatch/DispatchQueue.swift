import Foundation
import Dispatch

extension DispatchQueue {
    var isCurrent: Bool {
        let isCurrentQueueKey = DispatchSpecificKey<Bool>()

        self.setSpecific(key: isCurrentQueueKey, value: true)
        defer {
            self.setSpecific(key: isCurrentQueueKey, value: nil)
        }

        return DispatchQueue.getSpecific(key: isCurrentQueueKey) == true
    }

    func safeSync<T>(_ block: () throws -> T) rethrows -> T {
        guard isCurrent else {
            return try sync { try block() }
        }

        return try block()
    }
}
