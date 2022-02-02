// Atomic.swift
// Copyright (c) 2022 FastlaneTools

import Foundation

protocol DictionaryProtocol: class {
    associatedtype Key: Hashable
    associatedtype Value

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

    func lock()
    func unlock()
}

protocol AnyLock {}

extension UnsafeMutablePointer: AnyLock {
    @available(macOS, deprecated: 10.12)
    static func make() -> Self where Pointee == OSSpinLock {
        let spin = UnsafeMutablePointer<OSSpinLock>.allocate(capacity: 1)
        spin.initialize(to: OS_SPINLOCK_INIT)
        return spin
    }

    @available(macOS, introduced: 10.12)
    static func make() -> Self where Pointee == os_unfair_lock {
        let unfairLock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
        return unfairLock
    }

    @available(macOS, deprecated: 10.12)
    static func lock(_ lock: Self) where Pointee == OSSpinLock {
        OSSpinLockLock(lock)
    }

    @available(macOS, deprecated: 10.12)
    static func unlock(_ lock: Self) where Pointee == OSSpinLock {
        OSSpinLockUnlock(lock)
    }

    @available(macOS, introduced: 10.12)
    static func lock(_ lock: Self) where Pointee == os_unfair_lock {
        os_unfair_lock_lock(lock)
    }

    @available(macOS, introduced: 10.12)
    static func unlock(_ lock: Self) where Pointee == os_unfair_lock {
        os_unfair_lock_unlock(lock)
    }
}

// MARK: - Classes

class AtomicDictionary<Key: Hashable, Value>: LockProtocol {
    typealias Lock = AnyLock

    var _lock: Lock

    private var storage: [Key: Value] = [:]

    init(_ lock: Lock) {
        _lock = lock
    }

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

    func lock() {
        fatalError()
    }

    func unlock() {
        fatalError()
    }
}

@available(macOS, introduced: 10.12)
final class UnfairAtomicDictionary<Key: Hashable, Value>: AtomicDictionary<Key, Value> {
    typealias Lock = UnsafeMutablePointer<os_unfair_lock>

    init() {
        super.init(Lock.make())
    }

    override func lock() {
        Lock.lock(_lock as! Lock)
    }

    override func unlock() {
        Lock.unlock(_lock as! Lock)
    }
}

@available(macOS, deprecated: 10.12)
final class OSSPinAtomicDictionary<Key: Hashable, Value>: AtomicDictionary<Key, Value> {
    typealias Lock = UnsafeMutablePointer<OSSpinLock>

    init() {
        super.init(Lock.make())
    }

    override func lock() {
        Lock.lock(_lock as! Lock)
    }

    override func unlock() {
        Lock.unlock(_lock as! Lock)
    }
}
