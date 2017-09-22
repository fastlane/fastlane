//
//  RubyCommand.swift
//  SwiftRubyRPC
//
//  Created by Joshua Liebowitz on 8/4/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

protocol RubyCommandable {
    var json: String { get }
}

struct RubyCommand: RubyCommandable {
    struct Argument {
        let name: String
        let value: Any?
        let type: String? = nil

        var hasValue: Bool {
            return nil != self.value
        }

        var json: String {
            get {
                if let someValue = value {
                    return "{\"name\" : \"\(name)\", \"value\" : \"\(someValue)\"}"
                } else {
                    // Just exclude this arg if it doesn't have a value
                    return ""
                }
            }
        }
    }

    let commandID: String
    let methodName: String
    let className: String?
    let args: [Argument]

    var json: String {
        let argsArrayJson = self.args
            .map { $0.json }
            .filter { $0 != "" }

        let argsJson: String?
        if argsArrayJson.count > 0 {
            argsJson = "\"args\" : [\(argsArrayJson.joined(separator: ","))]"
        } else {
            argsJson = nil
        }

        let commandIDJson = "\"commandID\" : \"\(commandID)\""
        let methodNameJson = "\"methodName\" : \"\(methodName)\""

        var jsonParts = [commandIDJson, methodNameJson]
        if let argsJson = argsJson {
            jsonParts.append(argsJson)
        }

        if let className = className {
            let classNameJson = "\"className\" : \"\(className)\""
            jsonParts.append(classNameJson)
        }

        let commandJsonString = "{\(jsonParts.joined(separator: ","))}"

        return commandJsonString
    }
}
