// ConfigItem.swift
// Copyright (c) 2021 FastlaneTools

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

public enum ConfigItem<T> {
    case fastlaneDefault(T)
    case userDefined(T)
    case `nil`

    public func get() -> T {
        switch self {
        case let .fastlaneDefault(value):
            return value
        case let .userDefined(value):
            return value
        case .nil:
            preconditionFailure("\(#function) was called from a `ConfigItem.nil`, yet its matching Ruby config item is not optional")
        }
    }
}

extension Optional: ExpressibleByIntegerLiteral where Wrapped: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Wrapped.IntegerLiteralType

    public init(integerLiteral value: Wrapped.IntegerLiteralType) {
        self = .some(.init(integerLiteral: value))
    }
}

extension Optional: ExpressibleByUnicodeScalarLiteral where Wrapped: ExpressibleByUnicodeScalarLiteral {
    public typealias UnicodeScalarLiteralType = Wrapped.UnicodeScalarLiteralType

    public init(unicodeScalarLiteral value: Wrapped.UnicodeScalarLiteralType) {
        self = .some(.init(unicodeScalarLiteral: value))
    }
}

extension Optional: ExpressibleByExtendedGraphemeClusterLiteral where Wrapped: ExpressibleByStringLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = Wrapped.ExtendedGraphemeClusterLiteralType

    public init(extendedGraphemeClusterLiteral value: Wrapped.ExtendedGraphemeClusterLiteralType) {
        self = .some(.init(extendedGraphemeClusterLiteral: value))
    }
}

extension Optional: ExpressibleByStringLiteral where Wrapped: ExpressibleByStringLiteral {
    public typealias StringLiteralType = Wrapped.StringLiteralType

    public init(stringLiteral value: Wrapped.StringLiteralType) {
        self = .some(.init(stringLiteral: value))
    }
}

extension ConfigItem: ExpressibleByUnicodeScalarLiteral where T == String? {
    public typealias UnicodeScalarLiteralType = String
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .userDefined(value)
    }
}

extension ConfigItem: ExpressibleByExtendedGraphemeClusterLiteral where T == String? {
    public typealias ExtendedGraphemeClusterLiteralType = String
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .userDefined(value)
    }
}

extension ConfigItem: ExpressibleByStringLiteral where T == String? {
    public typealias StringLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        self = .userDefined(value)
    }
}

extension ConfigItem: ExpressibleByNilLiteral {
    public init(nilLiteral _: ()) {
        self = .nil
    }
}

extension ConfigItem: ExpressibleByIntegerLiteral where T == Int? {
    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: IntegerLiteralType) {
        self = .userDefined(value)
    }
}

extension ConfigItem: ExpressibleByArrayLiteral where T == [String] {
    public typealias ArrayLiteralElement = String

    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self = .userDefined(elements)
    }
}

extension ConfigItem: ExpressibleByFloatLiteral where T == Float {
    public typealias FloatLiteralType = Float

    public init(floatLiteral value: FloatLiteralType) {
        self = .userDefined(value)
    }
}

extension ConfigItem: ExpressibleByBooleanLiteral where T == Bool {
    public typealias BooleanLiteralType = Bool

    public init(booleanLiteral value: BooleanLiteralType) {
        self = .userDefined(value)
    }
}

extension ConfigItem: ExpressibleByDictionaryLiteral where T == [String: Any] {
    public typealias Key = String

    public typealias Value = Any

    public init(dictionaryLiteral elements: (String, Any)...) {
        var dict: [String: Any] = [:]
        elements.forEach {
            dict[$0.0] = $0.1
        }
        self = .userDefined(dict)
    }
}
