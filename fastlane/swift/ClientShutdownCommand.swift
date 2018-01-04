//
//  ClientShutdownCommand.swift
//  FastlaneRunner
//
//  Created by Joshua Liebowitz on 1/3/18.
//  Copyright © 2018 Joshua Liebowitz. All rights reserved.
//

import Foundation

struct ClientShutdownCommand: RubyCommandable {
    let message: String
    var json: String {
        let jsonDictionary: [String: Any] = ["commandID" : SocketClient.cancelToken,
                                             "args" : [["name" : "message", "value" : message]]]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
