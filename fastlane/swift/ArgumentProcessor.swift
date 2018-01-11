//
//  ArgumentProcessor.swift
//  FastlaneRunner
//
//  Created by Joshua Liebowitz on 9/28/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

struct ArgumentProcessor {
    let args: [RunnerArgument]
    let currentLane: String
    let commandTimeout: Int
    
    init(args: [String]) {        
        // Dump the first arg which is the program name
        let fastlaneArgs = stride(from: 1, to: args.count - 1, by: 2).map {
            RunnerArgument(name: args[$0], value: args[$0+1])
        }
        self.args = fastlaneArgs
        
        let fastlaneArgsMinusLanes = fastlaneArgs.filter { arg in
            return arg.name.lowercased() != "lane"
        }
        
        let potentialLogMode = fastlaneArgsMinusLanes.filter { arg in
            return arg.name.lowercased() == "logmode"
        }
        
        // Configure logMode since we might need to use it before we finish parsing
        if let logModeArg = potentialLogMode.first {
            let logModeString = logModeArg.value
            Logger.logMode = Logger.LogMode(logMode: logModeString)
        }
        
        let lanes = self.args.filter { arg in
            return arg.name.lowercased() == "lane"
        }
        verbose(message: lanes.description)
        
        guard lanes.count == 1 else {
            let message = "You must have exactly one lane specified as an arg, here's what I got: \(lanes)"
            log(message: message)
            fatalError(message)
        }
        
        let lane = lanes.first!
        self.currentLane = lane.value
        
        // User might have configured a timeout for the socket connection
        let potentialTimeout = fastlaneArgsMinusLanes.filter { arg in
            return arg.name.lowercased() == "timeoutseconds"
        }
        
        if let logModeArg = potentialLogMode.first {
            let logModeString = logModeArg.value
            Logger.logMode = Logger.LogMode(logMode: logModeString)
        }
        
        if let timeoutArg = potentialTimeout.first {
            let timeoutString = timeoutArg.value
            self.commandTimeout = (timeoutString as NSString).integerValue
        } else {
            self.commandTimeout = SocketClient.defaultCommandTimeoutSeconds
        }
    }
    
    func laneParameters() -> [String : String] {
        let laneParametersArgs = self.args.filter { arg in
            let lowercasedName = arg.name.lowercased()
            return lowercasedName != "timeoutseconds" && lowercasedName != "lane" && lowercasedName != "logmode"
        }
        var laneParameters = [String : String]()
        for arg in laneParametersArgs {
            laneParameters[arg.name] = arg.value
        }
        return laneParameters
    }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
