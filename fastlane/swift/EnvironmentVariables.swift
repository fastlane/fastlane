//
//  EnvironmentVariables.swift
//  SwiftRubyRPC
//
//  Created by Joshua Liebowitz on 8/4/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

public struct EnvironmentVariables {
    let variables: [String : String]
    init(variableMap: [String : String]) {
        self.variables = variableMap
    }

    var json: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.variables)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            return jsonString as String
        } catch {
            print("Unable to parse environment variables: \(error.localizedDescription)")
            fatalError()
        }
    }
}
