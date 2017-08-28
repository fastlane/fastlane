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
        let value: Any

        var json: String {
            get {
                return "{\"name\" : \"\(name)\", \"value\" : \"\(value)\"}"
            }
        }
    }

    let commandID: String
    let methodName: String
    let className: String?
    let args: [Argument]

    var json: String {
        let argsArrayJson = self.args.map { $0.json }
        let argsJson = "[\(argsArrayJson.joined(separator: ","))]"

        let commandIDJson = "\"commandID\" : \"\(commandID)\""
        let methodNameJson = "\"methodName\" : \"\(methodName)\""

        var jsonParts = [commandIDJson, methodNameJson, argsJson]

        if let className = className {
            let classNameJson = "\"className\" : \"\(className)\""
            jsonParts.append(classNameJson)
        }

        let commandJsonString = "{\(jsonParts.joined(separator: ","))}"

        return commandJsonString
    }
}
