//
//  FileObservation.swift
//
//

import Foundation

open class FileObservation {
    private static let mainQueue = DispatchQueue(
        label: "\(String(reflecting: FileObservation.self)).main",
        qos: .default,
        target: .global()
    )

    private let fsObjectSource: DispatchSourceFileSystemObject

    private init(path: String, handler: @escaping () -> Void) {
        let fileDescriptor = open(path, O_EVTONLY)

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
    class func observe(atPath path: String, handler: @escaping () -> Void) -> FileObservation {
        FileObservation(path: path, handler: handler)
    }

    class func observe(at url: URL, handler: @escaping () -> Void) -> FileObservation {
        observe(atPath: url.standardizedFileURL.path, handler: handler)
    }
}
