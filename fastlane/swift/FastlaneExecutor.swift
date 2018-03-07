import Foundation
import FastlaneSwift
import FastlaneSwiftShared
import FastlaneSwiftRunner

let argumentProcessor = ArgumentProcessor(args: CommandLine.arguments)
let timeout = argumentProcessor.commandTimeout

class MainProcess {
    var doneRunningLane = false
    var thread: Thread!
    
    @objc func connectToFastlaneAndRunLane() {
        runner = Runner(timeout: timeout)

        runner.startSocketThread()

        let completedRun = Fastfile.runLane(named: argumentProcessor.currentLane, parameters: argumentProcessor.laneParameters())
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

let process: MainProcess = MainProcess()
process.startFastlaneThread()

while (!process.doneRunningLane && (RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date(timeIntervalSinceNow: 2)))) {
    // no op
}
