// MainProcess.swift
// Copyright (c) 2021 FastlaneTools

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation
#if canImport(SwiftShell)
    import SwiftShell
#endif

let argumentProcessor = ArgumentProcessor(args: CommandLine.arguments)
let timeout = argumentProcessor.commandTimeout

class MainProcess {
    var doneRunningLane = false
    var thread: Thread!
    #if SWIFT_PACKAGE
        var lastPrintDate = Date.distantFuture
        var timeBetweenPrints = Int.min
        var rubySocketCommand: AsyncCommand!
    #endif

    @objc func connectToFastlaneAndRunLane(_ fastfile: LaneFile?) {
        runner.startSocketThread(port: argumentProcessor.port)

        let completedRun = Fastfile.runLane(from: fastfile, named: argumentProcessor.currentLane, with: argumentProcessor.laneParameters())
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
        #if SWIFT_PACKAGE
            let PATH = run("/bin/bash", "-c", "-l", "eval $(/usr/libexec/path_helper -s) ; echo $PATH").stdout
            main.env["PATH"] = PATH
            let path = main.run(bash: "which fastlane").stdout
            let pids = main.run("lsof", "-t", "-i", ":2000").stdout.split(separator: "\n")
            pids.forEach { main.run("kill", "-9", $0) }
            rubySocketCommand = main.runAsync(path, "socket_server", "-c", "1200")
            lastPrintDate = Date()
            rubySocketCommand.stderror.onStringOutput { print($0) }
            rubySocketCommand.stdout.onStringOutput { stdout in
                print(stdout)
                self.timeBetweenPrints = Int(self.lastPrintDate.timeIntervalSinceNow)
            }

            // swiftformat:disable:next redundantSelf
            _ = Runner.waitWithPolling(self.timeBetweenPrints, toEventually: { $0 > 5 }, timeout: 10)
            thread.start()
        #endif
    }
}

public class Main {
    let process = MainProcess()

    public init() {}

    public func run(with fastFile: LaneFile?) {
        process.startFastlaneThread(with: fastFile)

        while !process.doneRunningLane, RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 2)) {
            // no op
        }
    }
}
