import Foundation

open class FileObservation {
    private static let mainQueue = DispatchQueue(
        label: "\(String(reflecting: FileObservation.self)).main",
        qos: .default,
        target: .global()
    )

    private let fsObjectSource: DispatchSourceFileSystemObject

    private init(path: String, handler: @escaping () -> Void) throws {
        let fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno)!)
        }

        fsObjectSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: Self.mainQueue
        )

        fsObjectSource.setEventHandler(handler: handler)

        fsObjectSource.setCancelHandler {
            close(fileDescriptor)
        }

        fsObjectSource.resume()
    }

    deinit {
        fsObjectSource.cancel()
    }
}

extension FileObservation {
    open class func observe(atPath path: String, handler: @escaping () -> Void) throws -> FileObservation {
        try FileObservation(path: path, handler: handler)
    }

    open class func observe(at url: URL, handler: @escaping () -> Void) throws -> FileObservation {
        try observe(atPath: url.standardizedFileURL.path, handler: handler)
    }
}
