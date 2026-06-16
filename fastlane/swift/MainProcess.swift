// MainProcess.swift
// Copyright (c) 2026 FastlaneTools

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
    #if SWIFT_PACKAGE
        var rubySocketCommand: Process!
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
            killExistingSocketServerProcesses(port: argumentProcessor.port)

            rubySocketCommand = Process()
            rubySocketCommand.launchPath = "/usr/bin/env"
            rubySocketCommand.arguments = fastlaneLaunchArguments() + ["socket_server", "-c", String(timeout), "-p", String(argumentProcessor.port)]
            rubySocketCommand.launch()

            waitUntilSocketServerIsListening(port: argumentProcessor.port, serverProcess: rubySocketCommand)
            thread.start()
        #endif
    }

    #if SWIFT_PACKAGE
        // Resolves how to invoke fastlane, replacing the previous login-shell
        // `eval $(path_helper)` + `which fastlane` lookup that broke under
        // rbenv / bundler / system-ruby mixes (#29238). First match wins:
        // 1. FASTLANE_SPM_BIN environment variable (explicit override)
        // 2. bundler binstub ./bin/fastlane
        // 3. Gemfile in the working directory -> bundle exec fastlane
        // 4. fastlane on PATH
        private func fastlaneLaunchArguments() -> [String] {
            if let bin = ProcessInfo.processInfo.environment["FASTLANE_SPM_BIN"] {
                // split(separator:) omits empty subsequences, so a blank or
                // whitespace-only value yields an empty argv; fall through to
                // the normal resolution chain instead of launching `env` with
                // no command.
                let arguments = bin.split(separator: " ").map(String.init)
                if !arguments.isEmpty {
                    return arguments
                }
            }
            let workingDirectory = FileManager.default.currentDirectoryPath
            let binstub = workingDirectory + "/bin/fastlane"
            if FileManager.default.isExecutableFile(atPath: binstub) {
                return [binstub]
            }
            if FileManager.default.fileExists(atPath: workingDirectory + "/Gemfile") {
                return ["bundle", "exec", "fastlane"]
            }
            return ["fastlane"]
        }

        // The ruby socket server performs a single `accept` (see
        // fastlane/server/socket_server.rb), so probing readiness with a TCP
        // connection would consume that accept and shut the server down.
        // Poll the LISTEN state read-only via lsof instead of the previous
        // "stdout quiet for 5 seconds" heuristic.
        private func waitUntilSocketServerIsListening(port: UInt32, serverProcess: Process) {
            let deadline = Date(timeIntervalSinceNow: 30)
            while Date() < deadline {
                if !serverProcess.isRunning {
                    log(message: "fastlane socket_server exited with status \(serverProcess.terminationStatus) before listening. Check that the resolved fastlane installation works (e.g. `bundle exec fastlane --version`).")
                    exit(1)
                }
                if isPortListening(port) {
                    return
                }
                Thread.sleep(forTimeInterval: 0.2)
            }
            // Don't leak the socket server: it's still running (just not
            // listening yet) on this timeout path, so terminate it before exit.
            terminate(serverProcess: serverProcess)
            log(message: "fastlane socket_server did not start listening on port \(port) within 30 seconds")
            exit(1)
        }

        // Terminate the socket server, escalating SIGTERM to SIGKILL if it
        // doesn't exit promptly, so the timeout path never leaves an orphan.
        private func terminate(serverProcess: Process) {
            serverProcess.terminate()
            let killDeadline = Date(timeIntervalSinceNow: 2)
            while serverProcess.isRunning, Date() < killDeadline {
                Thread.sleep(forTimeInterval: 0.1)
            }
            if serverProcess.isRunning {
                _ = outputOfProcess(arguments: ["/bin/kill", "-9", String(serverProcess.processIdentifier)])
                serverProcess.waitUntilExit()
            }
        }

        // Clears a stale socket server left by a previously crashed run on this
        // port. Scoped to LISTENing ruby processes (`-sTCP:LISTEN -a -c ruby`)
        // so it never kills an unrelated service or a connected client that
        // happens to share the port.
        private func killExistingSocketServerProcesses(port: UInt32) {
            let pids = outputOfProcess(arguments: [lsofPath, "-t", "-nP", "-iTCP:\(port)", "-sTCP:LISTEN", "-a", "-c", "ruby"])
                .split(separator: "\n")
            pids.forEach { _ = outputOfProcess(arguments: ["/bin/kill", "-9", String($0)]) }
        }

        private func isPortListening(_ port: UInt32) -> Bool {
            let result = runProcess(arguments: [lsofPath, "-t", "-nP", "-iTCP:\(port)", "-sTCP:LISTEN"])
            // `env` exits 127 when lsof can't be found. Without this guard the
            // probe would silently return false on every poll, then kill the
            // freshly launched server after the 30s timeout with a misleading
            // "did not start listening" message. Fail fast with the real cause.
            if result.status == 127 {
                log(message: "Could not run lsof (\(lsofPath)) to check socket server readiness. lsof ships at /usr/sbin/lsof on macOS; ensure it is installed and reachable.")
                exit(1)
            }
            return !result.output.isEmpty
        }

        // Prefer the absolute macOS path so port checks don't depend on PATH;
        // fall back to a PATH lookup if lsof lives somewhere non-standard.
        private var lsofPath: String {
            let standardPath = "/usr/sbin/lsof"
            return FileManager.default.isExecutableFile(atPath: standardPath) ? standardPath : "lsof"
        }

        private func outputOfProcess(arguments: [String]) -> String {
            return runProcess(arguments: arguments).output
        }

        private func runProcess(arguments: [String]) -> (output: String, status: Int32) {
            let process = Process()
            let pipe = Pipe()
            process.launchPath = "/usr/bin/env"
            process.arguments = arguments
            process.standardOutput = pipe
            process.standardError = FileHandle.nullDevice
            process.launch()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return (String(data: data, encoding: .utf8) ?? "", process.terminationStatus)
        }
    #endif
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
