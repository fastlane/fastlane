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

protocol LockProtocol: DictionaryProtocol {
    associatedtype Lock

    var _lock: Lock { get set }
}

extension LockProtocol {
    func lock() {
        if #available(macOS 10.12, *), let _lock = _lock as? UnsafeMutablePointer<os_unfair_lock> {
            os_unfair_lock_lock(_lock)
        } else if var _lock = _lock as? Int32 {
            OSSpinLockLock(&_lock)
        }
    }

    func unlock() {
        if #available(macOS 10.12, *), let _lock = _lock as? UnsafeMutablePointer<os_unfair_lock> {
            os_unfair_lock_unlock(_lock)
        } else if var _lock = _lock as? Int32 {
            OSSpinLockUnlock(&_lock)
        }
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
        lock()
        defer { unlock() }
        return storage.removeValue(forKey: key)
    }

    func get(_ key: Key) -> Value? {
        lock()
        defer { unlock() }
        return storage[key]
    }

    func set(_ key: Key, value: Value?) {
        lock()
        defer { unlock() }
        storage[key] = value
    }
}

@available(macOS, deprecated: 10.12)
class OSSPinAtomicDictionary<Key: Hashable, Value>: AtomicDictionary<Key, Value> {}

@available(macOS, introduced: 10.12)
class UnfairAtomicDictionary<Key: Hashable, Value>: AtomicDictionary<Key, Value> {

    deinit {
        (_lock as? UnsafeMutablePointer<os_unfair_lock>)?.deallocate()
    }
}
