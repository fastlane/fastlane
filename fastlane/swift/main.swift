//
//  main.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 8/26/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

let args: [String] = CommandLine.arguments

// Dump the first arg which is the program name
let fastlaneArgs = stride(from: 1, to: args.count - 1, by: 2).map {
    RunnerArgument(name: args[$0], value: args[$0+1])
}

let lanes = fastlaneArgs.filter { arg in
    return arg.name.lowercased() == "lane"
}

let fastlaneArgsMinusLanes = fastlaneArgs.filter { arg in
    return arg.name.lowercased() != "lane"
}

let potentialLogMode = fastlaneArgsMinusLanes.filter { arg in
    return arg.name.lowercased() == "logMode"
}

// Configure logMode since we might need to use it before we finish parsing
if let logModeArg = potentialLogMode.first {
    let logModeString = logModeArg.value
    Logger.logMode = Logger.LogMode(logMode: logModeString)
}

// User might have configured a timeout for the socket connection
let potentialTimeout = fastlaneArgsMinusLanes.filter { arg in
    return arg.name.lowercased() == "timeoutSeconds"
}

verbose(message: lanes.description)

guard lanes.count == 1 else {
    let message = "You must have exactly one lane specified as an arg, here's what I got: \(lanes)"
    log(message: message)
    fatalError(message)
}

let lane = lanes.first!

if let logModeArg = potentialLogMode.first {
    let logModeString = logModeArg.value
    Logger.logMode = Logger.LogMode(logMode: logModeString)
}

let timeout: Int
if let timeoutArg = potentialTimeout.first {
    let timeoutString = timeoutArg.value
    timeout = (timeoutString as NSString).integerValue
} else {
    timeout = SocketClient.defaultCommandTimeoutSeconds
}

class MainProcess {
    var doneRunningLane = false
    var thread: Thread!

    @objc func connectToFastlaneAndRunLane() {
        runner.startSocketThread()

        Fastfile.runLane(named: lane.value)
        runner.disconnectFromFastlaneProcess()

        doneRunningLane = true
    }

    func startFastlaneThread() {
        thread = Thread(target: self, selector: #selector(connectToFastlaneAndRunLane), object: nil)
        thread.name = "worker thread"
        thread.start()
    }
}

let process: MainProcess = MainProcess()
process.startFastlaneThread()

while (!process.doneRunningLane && (RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 2)))) {
// no op
}
