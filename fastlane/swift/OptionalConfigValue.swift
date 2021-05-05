// OptionalConfigValue.swift
// Copyright (c) 2021 FastlaneTools

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

public enum OptionalConfigValue<T> {
    case fastlaneDefault(T)
    case userDefined(T)
    case `nil`

    func asRubyArgument(name: String, type: RubyCommand.Argument.ArgType? = nil) -> RubyCommand.Argument? {
        if case let .userDefined(value) = self {
            return RubyCommand.Argument(name: name, value: value, type: type)
        }
        return nil
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

extension OptionalConfigValue: ExpressibleByUnicodeScalarLiteral where T == String? {
    public typealias UnicodeScalarLiteralType = String

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .userDefined(value)
    }
}

extension OptionalConfigValue: ExpressibleByExtendedGraphemeClusterLiteral where T == String? {
    public typealias ExtendedGraphemeClusterLiteralType = String

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self = .userDefined(value)
    }
}

extension OptionalConfigValue: ExpressibleByStringLiteral where T == String? {
    public typealias StringLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        self = .userDefined(value)
    }
}

extension OptionalConfigValue: ExpressibleByNilLiteral {
    public init(nilLiteral _: ()) {
        self = .nil
    }
}

extension OptionalConfigValue: ExpressibleByIntegerLiteral where T == Int? {
    public typealias IntegerLiteralType = Int

    public init(integerLiteral value: IntegerLiteralType) {
        self = .userDefined(value)
    }
}

extension OptionalConfigValue: ExpressibleByArrayLiteral where T == [String] {
    public typealias ArrayLiteralElement = String

    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self = .userDefined(elements)
    }
}

extension OptionalConfigValue: ExpressibleByFloatLiteral where T == Float {
    public typealias FloatLiteralType = Float

    public init(floatLiteral value: FloatLiteralType) {
        self = .userDefined(value)
    }
}

extension OptionalConfigValue: ExpressibleByBooleanLiteral where T == Bool {
    public typealias BooleanLiteralType = Bool

    public init(booleanLiteral value: BooleanLiteralType) {
        self = .userDefined(value)
    }
}

extension OptionalConfigValue: ExpressibleByDictionaryLiteral where T == [String: Any] {
    public typealias Key = String
    public typealias Value = Any

    public init(dictionaryLiteral elements: (Key, Value)...) {
        var dict: [Key: Value] = [:]
        elements.forEach {
            dict[$0.0] = $0.1
        }
        self = .userDefined(dict)
    }
}
