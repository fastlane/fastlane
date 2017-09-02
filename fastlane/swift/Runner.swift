//
//  Runner.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 8/26/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

let runner: Runner = {
    let runner = Runner()
    return runner
}()

class Runner {
    fileprivate var thread: Thread!
    fileprivate var socketClient: SocketClient!
    fileprivate let dispatchGroup: DispatchGroup = DispatchGroup()
    fileprivate var returnValue: Any? //lol

    init() {
        startSocketThread()
    }

    func executeCommand(_ command: RubyCommandable) -> Any {
        self.dispatchGroup.enter()
        socketClient.send(rubyCommand: command)

        let secondsToWait = DispatchTimeInterval.seconds(SocketClient.connectTimeoutSeconds)
        let connectTimeout = DispatchTime.now() + secondsToWait
        let timeoutResult = self.dispatchGroup.wait(timeout: connectTimeout)
        let failureMessage = "command didn't execute in: \(SocketClient.connectTimeoutSeconds) seconds"
        let success = testDispatchTimeoutResult(timeoutResult, failureMessage: failureMessage, timeToWait: secondsToWait)
        guard success else {
            fatalError("command timeout")
        }

        if let returnValue = self.returnValue {
            return returnValue
        } else {
            return ""
        }
    }

    func log(message: String) {
        let timestamp = NSDate().timeIntervalSince1970
        print("[\(timestamp)]: \(message)\n")
    }
}

// Handle threading stuff
extension Runner {
    func startSocketThread() {
        self.socketClient = SocketClient(socketDelegate: self)
        self.thread = Thread(target: self, selector: #selector(startSocketComs), object: nil)
        self.thread!.name = "socket thread"
        self.thread!.start()
    }

    @objc func startSocketComs() {
        guard let socketClient = self.socketClient else {
            return
        }

        socketClient.connectAndOpenStreams()
    }

    fileprivate func testDispatchTimeoutResult(_ timeoutResult: DispatchTimeoutResult, failureMessage: String, timeToWait: DispatchTimeInterval) -> Bool {
        switch timeoutResult {
        case .success:
            return true
        case .timedOut:
            log(message: "timeout: \(failureMessage)")
            return false
        }
    }
}

extension Runner : SocketClientDelegateProtocol {
    func commandExecuted(error: SocketClientError?) {
        guard let error = error else {
            log(message: "command executed")
            return
        }

        log(message: "error encountered while executing command:\n\(error)")

        self.dispatchGroup.leave()
    }

    func connectionsOpened() {
        DispatchQueue.main.async {
            self.log(message: "connected!")
        }
    }

    func connectionsClosed() {
        DispatchQueue.main.async {
            self.thread?.cancel()
            self.thread = nil
            self.socketClient = nil
            self.log(message: "connection closed!")
        }
    }
}
