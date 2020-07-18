// MainProcess.swift
// Copyright (c) 2020 FastlaneTools

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

let argumentProcessor = ArgumentProcessor(args: CommandLine.arguments)
let timeout = argumentProcessor.commandTimeout

class MainProcess {
    var doneRunningLane = false
    var thread: Thread!

    @objc func connectToFastlaneAndRunLane(_ fastfile: LaneFile?) {
        runner.startSocketThread(port: argumentProcessor.port)

        let completedRun = Fastfile.runLane(from: fastfile, named: argumentProcessor.currentLane, parameters: argumentProcessor.laneParameters())
        if completedRun {
            runner.disconnectFromFastlaneProcess()
        }

        doneRunningLane = true
    }

    func startFastlaneThread(with fastFile: LaneFile?) {
        #if !SWIFT_PACKAGE
            thread = Thread(target: self, selector: #selector(connectToFastlaneAndRunLane), object: nil)
        #else
            thread = Thread(target: self, selector: #selector(connectToFastlaneAndRunLane), object: fastFile)
        #endif
        thread.name = "worker thread"
        thread.start()
    }
}

public class Main {
    let process: MainProcess = MainProcess()

    public init() {}

    public func run(with fastFile: LaneFile?) {
        process.startFastlaneThread(with: fastFile)

        while !process.doneRunningLane, RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 2)) {
            // no op
        }
    }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
