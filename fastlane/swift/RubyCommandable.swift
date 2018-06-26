//
//  RubyCommandable.swift
//  FastlaneRunner
//
//  Created by Joshua Liebowitz on 1/4/18.
//

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

enum CommandType {
    case action
    case control

    var token: String {
        switch self {
        case .action:
            return "action"
        case .control:
            return "control"
        }
    }
}

protocol RubyCommandable {
    var type: CommandType { get }
    var commandJson: String { get }
}

extension RubyCommandable {
    var json: String {
        return "{\"commandType\" : \"\(self.type.token)\", \"command\" : \(self.commandJson)}"
    }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
