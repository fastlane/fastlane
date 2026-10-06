// main.swift
// Copyright (c) 2026 FastlaneTools

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

let argumentProcessor = ArgumentProcessor(args: CommandLine.arguments)
/// fastlane reads this from the built runner, to tell whether it is outdated. Increase it when the runner changes how it talks to fastlane.
let runnerProtocolVersion = "FastlaneRunnerProtocolVersion [1]"
verbose(message: runnerProtocolVersion)
let timeout = argumentProcessor.commandTimeout

class MainProcess {
    var doneRunningLane = false
    var thread: Thread!

    @objc func connectToFastlaneAndRunLane() {
        runner.startSocketThread(port: argumentProcessor.port)

        let completedRun = Fastfile.runLane(from: nil, named: argumentProcessor.currentLane, with: argumentProcessor.laneParameters())
        if completedRun {
            runner.disconnectFromFastlaneProcess()
        }

        doneRunningLane = true
    }

    func startFastlaneThread() {
        thread = Thread(target: self, selector: #selector(connectToFastlaneAndRunLane), object: nil)
        thread.name = "worker thread"
        thread.start()
    }
}

let process = MainProcess()
process.startFastlaneThread()

while !process.doneRunningLane, RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 2)) {
    // no op
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.3]
