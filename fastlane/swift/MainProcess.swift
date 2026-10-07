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
            abortIfPortIsInUse(argumentProcessor.port)

            rubySocketCommand = Process()
            rubySocketCommand.launchPath = "/usr/bin/env"
            rubySocketCommand.arguments = fastlaneLaunchArguments() + ["socket_server", "-c", String(timeout), "-p", String(argumentProcessor.port)]
            rubySocketCommand.launch()

            waitUntilSocketServerIsListening(port: argumentProcessor.port, serverProcess: rubySocketCommand)
            thread.start()
        #endif
    }

    #if SWIFT_PACKAGE
        /// Resolves how to invoke fastlane, replacing the previous login-shell
        /// `eval $(path_helper)` + `which fastlane` lookup that broke under
        /// rbenv / bundler / system-ruby mixes (#29238). First match wins:
        /// 1. FASTLANE_SPM_BIN environment variable (explicit override)
        /// 2. bundler binstub bin/fastlane next to the Gemfile
        /// 3. Gemfile (BUNDLE_GEMFILE, or found from the working directory up, as Bundler does) -> bundle exec fastlane
        /// 4. fastlane on PATH
        func fastlaneLaunchArguments() -> [String] {
            if let bin = ProcessInfo.processInfo.environment["FASTLANE_SPM_BIN"],
               !bin.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            {
                // The shell splits the value, so quoted paths with spaces work; our arguments
                // pass through "$@" untouched, and exec keeps the launched process ID.
                return ["/bin/sh", "-c", "exec \(bin) \"$@\"", "sh"]
            }
            guard let bundleRoot = bundleRootDirectory() else {
                return ["fastlane"]
            }
            let binstub = bundleRoot + "/bin/fastlane"
            if FileManager.default.isExecutableFile(atPath: binstub) {
                return [binstub]
            }
            return ["bundle", "exec", "fastlane"]
        }

        /// The directory of the Gemfile Bundler would use: BUNDLE_GEMFILE, else the
        /// nearest Gemfile or gems.rb from the working directory up.
        func bundleRootDirectory() -> String? {
            let workingDirectory = FileManager.default.currentDirectoryPath
            if let gemfile = ProcessInfo.processInfo.environment["BUNDLE_GEMFILE"], !gemfile.isEmpty {
                let path = gemfile.hasPrefix("/") ? gemfile : workingDirectory + "/" + gemfile
                return (path as NSString).deletingLastPathComponent
            }
            var directory = workingDirectory
            while true {
                for name in ["Gemfile", "gems.rb"] where FileManager.default.fileExists(atPath: directory + "/" + name) {
                    return directory
                }
                let parent = (directory as NSString).deletingLastPathComponent
                if parent == directory || parent.isEmpty {
                    return nil
                }
                directory = parent
            }
        }

        /// The ruby socket server performs a single `accept` (see
        /// fastlane/server/socket_server.rb), so probing readiness with a TCP
        /// connection would consume that accept and shut the server down.
        /// Poll the LISTEN state read-only via lsof instead of the previous
        /// "stdout quiet for 5 seconds" heuristic.
        private func waitUntilSocketServerIsListening(port: UInt32, serverProcess: Process) {
            let deadline = Date(timeIntervalSinceNow: 30)
            while Date() < deadline {
                if !serverProcess.isRunning {
                    log(message: "fastlane socket_server exited with status \(serverProcess.terminationStatus) before listening. Check that the resolved fastlane installation works (e.g. `bundle exec fastlane --version`).")
                    exit(1)
                }
                if isPortListening(port, by: serverProcess.processIdentifier) {
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

        /// Terminate the socket server, escalating SIGTERM to SIGKILL if it
        /// doesn't exit promptly, so the timeout path never leaves an orphan.
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

        /// Clears a stale socket server left by a previously crashed run on this
        /// port. Scoped to LISTENing ruby processes (`-sTCP:LISTEN -a -c ruby`)
        /// so it never kills an unrelated service or a connected client that
        /// happens to share the port.
        private func killExistingSocketServerProcesses(port: UInt32) {
            let pids = outputOfProcess(arguments: [lsofPath, "-t", "-nP", "-iTCP:\(port)", "-sTCP:LISTEN", "-a", "-c", "ruby"])
                .split(separator: "\n")
            pids.forEach { _ = outputOfProcess(arguments: ["/bin/kill", "-9", String($0)]) }
        }

        /// socket_server listens on whichever of 127.0.0.1 and ::1 is free, while the runner connects to `localhost`,
        /// so a process holding the port on either address would receive the runner's commands.
        private func abortIfPortIsInUse(_ port: UInt32) {
            guard isAddressInUse(family: AF_INET, port: port) || isAddressInUse(family: AF_INET6, port: port) else {
                return
            }
            // lsof only lists this user's processes unless run as root
            let holders = outputOfProcess(arguments: [lsofPath, "-nP", "-iTCP:\(port)", "-sTCP:LISTEN"])
            let holder = holders.isEmpty ? " by a process of another user" : ":\n\(holders)"
            log(message: "Port \(port) is already in use on localhost\(holder)\nStop it, or choose another port for the runner with `swiftServerPort`.")
            exit(1)
        }

        /// Binding fails with EADDRINUSE when another socket listens on that address and port, whoever owns it.
        func isAddressInUse(family: Int32, port: UInt32) -> Bool {
            let socketDescriptor = socket(family, SOCK_STREAM, 0)
            guard socketDescriptor >= 0 else {
                return false
            }
            defer { close(socketDescriptor) }
            // Ignore connections left in TIME_WAIT by an earlier run, as the Ruby server does
            var reuse: Int32 = 1
            setsockopt(socketDescriptor, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))

            let result: Int32
            if family == AF_INET {
                var address = sockaddr_in()
                address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
                address.sin_family = sa_family_t(AF_INET)
                address.sin_port = in_port_t(UInt16(port).bigEndian)
                address.sin_addr.s_addr = inet_addr("127.0.0.1")
                result = withUnsafePointer(to: &address) {
                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(socketDescriptor, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) }
                }
            } else {
                var address = sockaddr_in6()
                address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
                address.sin6_family = sa_family_t(AF_INET6)
                address.sin6_port = in_port_t(UInt16(port).bigEndian)
                address.sin6_addr = in6addr_loopback
                result = withUnsafePointer(to: &address) {
                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(socketDescriptor, $0, socklen_t(MemoryLayout<sockaddr_in6>.size)) }
                }
            }
            return result != 0 && errno == EADDRINUSE
        }

        /// Only the process we launched counts: another process listening on the port is not our server
        private func isPortListening(_ port: UInt32, by processIdentifier: Int32) -> Bool {
            let result = runProcess(arguments: [lsofPath, "-t", "-nP", "-iTCP:\(port)", "-sTCP:LISTEN"])
            // `env` exits 127 when lsof can't be found. Without this guard the
            // probe would silently return false on every poll, then kill the
            // freshly launched server after the 30s timeout with a misleading
            // "did not start listening" message. Fail fast with the real cause.
            if result.status == 127 {
                log(message: "Could not run lsof (\(lsofPath)) to check socket server readiness. lsof ships at /usr/sbin/lsof on macOS; ensure it is installed and reachable.")
                exit(1)
            }
            return result.output.split(separator: "\n").contains { $0 == Substring(String(processIdentifier)) }
        }

        /// Prefer the absolute macOS path so port checks don't depend on PATH;
        /// fall back to a PATH lookup if lsof lives somewhere non-standard.
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
