// Atomic.swift
// Copyright (c) 2021 FastlaneTools

import Foundation

protocol DictionaryProtocol: class {
    associatedtype Key: Hashable
    associatedtype Value

    init()

    subscript(_: Key) -> Value? { get set }

    @discardableResult
    func removeValue(forKey key: Key) -> Value?

    func get(_ key: Key) -> Value?
    func set(_ key: Key, value: Value?)
}

extension DictionaryProtocol {
    subscript(_ key: Key) -> Value? {
        get {
            get(key)
        }
        set {
            set(key, value: newValue)
        }
    }
}

protocol SyncProtocol: DictionaryProtocol {
    func lock()
    func unlock()
    func sync<T>(_ work: () throws -> T) rethrows -> T
}

extension SyncProtocol {
    func sync<T>(_ work: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try work()
    }
}

protocol LockProtocol: SyncProtocol {
    associatedtype Lock

    var _lock: Lock { get set }
}

@available(macOS, introduced: 10.12)
extension LockProtocol where Lock == UnsafeMutablePointer<os_unfair_lock> {
    func lock() {
        os_unfair_lock_lock(_lock)
    }

    func unlock() {
        os_unfair_lock_unlock(_lock)
    }
}

@available(macOS, deprecated: 10.12)
extension LockProtocol where Lock == OSSpinLock {
    func lock() {
        OSSpinLockLock(&_lock)
    }

    func unlock() {
        OSSpinLockUnlock(&_lock)
    }
}

protocol AnyLock {}

@available(macOS, deprecated: 10.12)
extension OSSpinLock: AnyLock {
    static func make() -> Self {
        OS_SPINLOCK_INIT
    }
}

@available(macOS, introduced: 10.12)
extension UnsafeMutablePointer: AnyLock where Pointee == os_unfair_lock {
    static func make() -> Self {
        let unfairLock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
        return unfairLock
    }
}

// MARK: - Classes

class AtomicDictionary<Key: Hashable, Value>: LockProtocol {
    typealias Lock = AnyLock

    var _lock: Lock = {
        if #available(macOS 10.12, *) {
            return UnsafeMutablePointer<os_unfair_lock>.make()
        } else {
            return OSSpinLock.make()
        }
    }()

    private var storage: [Key: Value] = [:]

    required init() {}

    @discardableResult
    func removeValue(forKey key: Key) -> Value? {
        sync {
            storage.removeValue(forKey: key)
        }
    }

    func get(_ key: Key) -> Value? {
        sync {
            storage[key]
        }
    }

    func set(_ key: Key, value: Value?) {
        sync {
            storage[key] = value
        }
    }

    func lock() {}

    func unlock() {}
}

@available(macOS, deprecated: 10.12)
class OSSPinAtomicDictionary<Key: Hashable, Value>: AtomicDictionary<Key, Value> {
    override func lock() {}
    override func unlock() {}
}

@available(macOS, introduced: 10.12)
class UnfairAtomicDictionary<Key: Hashable, Value>: AtomicDictionary<Key, Value> {
    override func lock() {}
    override func unlock() {}

    deinit {
        (_lock as? UnsafeMutablePointer<os_unfair_lock>)?.deallocate()
    }
}
