//
//  RubyCommand.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 8/4/17.
//

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

struct RubyCommand: RubyCommandable {
    var type: CommandType { return .action }

    struct Argument {
        enum ArgType {
            case stringClosure

            var typeString: String {
                switch self {
                case .stringClosure:
                    return "string_closure" // this should match when is in ruby's SocketServerActionCommandExecutor
                }
            }
        }

        let name: String
        let value: Any?
        let type: ArgType?

        init(name: String, value: Any?, type: ArgType? = nil) {
            self.name = name
            self.value = value
            self.type = type
        }

        var hasValue: Bool {
            return nil != self.value
        }

        var json: String {
            get {
                if let someValue = value {
                    let typeJson: String
                    if let type = type {
                        typeJson = ", \"value_type\" : \"\(type.typeString)\""
                    } else {
                        typeJson = ""
                    }

                    if type == .stringClosure  {
                        return "{\"name\" : \"\(name)\", \"value\" : \"ignored_for_closure\"\(typeJson)}"
                    } else if let array = someValue as? [String] {
                        return "{\"name\" : \"\(name)\", \"value\" : \"\(array.joined(separator: ","))\"\(typeJson)}"
                    } else if let hash = someValue as? [String : Any] {
                        let jsonData = try! JSONSerialization.data(withJSONObject: hash, options: [])
                        let jsonString = String(data: jsonData, encoding: .utf8)!
                        return "{\"name\" : \"\(name)\", \"value\" : \(jsonString)\(typeJson)}"
                    } else {
                        let dictionary = [
                            "name": name,
                            "value": someValue
                        ]
                        let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
                        let jsonString = String(data: jsonData, encoding: .utf8)!
                        return jsonString
                    }
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

    func performCallback(callbackArg: String) {
        // WARNING: This will perform the first callback it receives
        let callbacks = self.args.filter { ($0.type != nil) && $0.type == .stringClosure }
        guard let callback = callbacks.first else {
            verbose(message: "received call to performCallback with \(callbackArg), but no callback available to perform")
            return
        }

        guard let callbackArgValue = callback.value else {
            verbose(message: "received call to performCallback with \(callbackArg), but callback is nil")
            return
        }

        guard let callbackClosure = callbackArgValue as? ((String) -> Void) else {
            verbose(message: "received call to performCallback with \(callbackArg), but callback type is unknown \(callbackArgValue.self)")
            return
        }

        print("Performing callback with: \(callbackArg)")
        callbackClosure(callbackArg)
    }

    var commandJson: String {
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

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
