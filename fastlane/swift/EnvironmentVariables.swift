//
//  EnvironmentVariables.swift
//  SwiftRubyRPC
//
//  Created by Joshua Liebowitz on 8/4/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

public struct EnvironmentVariables {

    static var instance: EnvironmentVariables = { EnvironmentVariables() }()

    var variables: [String : String] = [ : ]

    subscript(key: String) -> String? {
        get {
            return self.variables[key]
        }

        set (newValue) {
            self.variables[key] = newValue
        }
    }
}

extension EnvironmentVariables: RubyCommandable {
    var json: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.variables)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            return jsonString as String
        } catch {
            let message = "Unable to parse environment variables: \(error.localizedDescription)"
            log(message: message)
            fatalError(message)
        }
    }
}
