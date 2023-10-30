import Combine
import Foundation.NSLock


/// A class that stores AnyCancellables and calls cancel method on each of them when deinit.
public final class CancelBag: Cancellable {

    private let lock = NSRecursiveLock()

    private var cancellables: Set<AnyCancellable> = []

    deinit {
        cancel()
    }

    public init() {}

    internal func insert(_ cancellable: AnyCancellable) {
        lock.lock()
        defer { lock.unlock() }
        cancellables.insert(cancellable)
    }


    /// Calls cancel method on
    public func cancel() {
        lock.lock()
        let cancellables = self.cancellables
        self.cancellables.removeAll()
        lock.unlock()
        cancellables.forEach { $0.cancel() }
    }
}

extension AnyCancellable {

    /// Convenient method that stores AnyCancellable itself to a CancelBag.
    /// - Parameter bag: the CancelBag to store the AnyCancellable object.
    public func store(in bag: CancelBag) {
        bag.insert(self)
    }
}


/// Declares one has a cancelBag property.
public protocol BeCancelable {
    var cancelBag: CancelBag { get }
}
