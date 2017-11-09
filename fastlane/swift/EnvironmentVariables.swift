//
//  EnvironmentVariables.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 8/4/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

typealias ENV = EnvironmentVariables

public struct EnvironmentVariables {
    public static var instance = EnvironmentVariables()

    subscript(key: String) -> String? {
        get {
            return EnvironmentVariables.get(key)
        }

        set (newValue) {
            if let newValue = newValue {
                EnvironmentVariables.set(key: key, value: newValue)
            } else {
                EnvironmentVariables.remove(key)
            }
        }
    }
    public static func get(_ key: String) -> String {
        return environmentVariable(get🚀: key)
    }
    
    public static func set(key: String, value: String) {
        environmentVariable(set🚀: [key : value] )
    }
    
    public static func remove(_ key: String) {
        environmentVariable(remove: key)
    }
}
