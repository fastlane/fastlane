//
//  main.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 8/26/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

let argumentProcessor = ArgumentProcessor(args: CommandLine.arguments)
let timeout = argumentProcessor.commandTimeout

class MainProcess {
    var doneRunningLane = false
    var thread: Thread!
    
    @objc func connectToFastlaneAndRunLane() {
        runner.startSocketThread()
        
        Fastfile.runLane(named: argumentProcessor.currentLane)
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

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.1]
