//
//  Runner.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 8/26/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

let logger: Logger = {
    return Logger()
}()

let runner: Runner = {
    return Runner()
}()

func desc(_ laneDescription: String) {
    // no-op, this is handled in fastlane/lane_list.rb
}

class Runner {
    fileprivate var thread: Thread!
    fileprivate var socketClient: SocketClient!
    fileprivate let dispatchGroup: DispatchGroup = DispatchGroup()
    fileprivate var returnValue: String? // lol, so safe
    fileprivate var currentlyExecutingCommand: RubyCommandable? = nil
    fileprivate var shouldLeaveDispatchGroupDuringDisconnect = false

    func executeCommand(_ command: RubyCommandable) -> String {
        self.dispatchGroup.enter()
        currentlyExecutingCommand = command
        socketClient.send(rubyCommand: command)
        
        let secondsToWait = DispatchTimeInterval.seconds(SocketClient.defaultCommandTimeoutSeconds)
        let connectTimeout = DispatchTime.now() + secondsToWait
        let timeoutResult = self.dispatchGroup.wait(timeout: connectTimeout)
        let failureMessage = "command didn't execute in: \(SocketClient.defaultCommandTimeoutSeconds) seconds"
        let success = testDispatchTimeoutResult(timeoutResult, failureMessage: failureMessage, timeToWait: secondsToWait)
        guard success else {
            log(message: "command timeout")
            fatalError()
        }
        
        if let returnValue = self.returnValue {
            return returnValue
        } else {
            return ""
        }
    }
}

// Handle threading stuff
extension Runner {
    func startSocketThread() {
        let secondsToWait = DispatchTimeInterval.seconds(SocketClient.connectTimeoutSeconds)
        
        self.dispatchGroup.enter()
        
        self.socketClient = SocketClient(commandTimeoutSeconds:timeout, socketDelegate: self)
        self.thread = Thread(target: self, selector: #selector(startSocketComs), object: nil)
        self.thread!.name = "socket thread"
        self.thread!.start()
        
        let connectTimeout = DispatchTime.now() + secondsToWait
        let timeoutResult = self.dispatchGroup.wait(timeout: connectTimeout)
        
        let failureMessage = "couldn't start socket thread in: \(SocketClient.connectTimeoutSeconds) seconds"
        let success = testDispatchTimeoutResult(timeoutResult, failureMessage: failureMessage, timeToWait: secondsToWait)
        guard success else {
            log(message: "socket thread timeout")
            fatalError()
        }
    }
    
    func disconnectFromFastlaneProcess() {
        self.shouldLeaveDispatchGroupDuringDisconnect = true
        self.dispatchGroup.enter()
        socketClient.sendComplete()
        
        let connectTimeout = DispatchTime.now() + 2
        _ = self.dispatchGroup.wait(timeout: connectTimeout)
    }
    
    @objc func startSocketComs() {
        guard let socketClient = self.socketClient else {
            return
        }

        socketClient.connectAndOpenStreams()
        self.dispatchGroup.leave()
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
    func commandExecuted(serverResponse: SocketClientResponse) {
        switch serverResponse {
        case .success(let returnedObject, let closureArgumentValue):
            verbose(message: "command executed")
            self.returnValue = returnedObject
            if let command = self.currentlyExecutingCommand as? RubyCommand {
                if let closureArgumentValue = closureArgumentValue {
                    command.performCallback(callbackArg: closureArgumentValue)
                }
            }
            self.dispatchGroup.leave()
        case .clientInitiatedCancelAcknowledged:
            verbose(message: "server acknowledged a cancel request")
            self.dispatchGroup.leave()

        case .alreadyClosedSockets, .connectionFailure, .malformedRequest, .malformedResponse, .serverError:
            log(message: "error encountered while executing command:\n\(serverResponse)")
            self.dispatchGroup.leave()

        case .commandTimeout(let timeout):
            log(message: "Runner timed out after \(timeout) second(s)")
        }
    }
    
    func connectionsOpened() {
        DispatchQueue.main.async {
            verbose(message: "connected!")
        }
    }
    
    func connectionsClosed() {
        DispatchQueue.main.async {
            self.thread?.cancel()
            self.thread = nil
            self.socketClient = nil
            verbose(message: "connection closed!")
            if self.shouldLeaveDispatchGroupDuringDisconnect {
                self.dispatchGroup.leave()
            }
            exit(0)
        }
    }
}

class Logger {
    enum LogMode {
        init(logMode: String) {
            switch logMode {
            case "normal", "default":
                self = .normal
            case "verbose":
                self = .verbose
            default:
                logger.log(message: "unrecognized log mode: \(logMode), defaulting to 'normal'")
                self = .normal
            }
        }
        case normal
        case verbose
    }
    
    public static var logMode: LogMode = .normal
    
    func log(message: String) {
        let timestamp = NSDate().timeIntervalSince1970
        print("[\(timestamp)]: \(message)")
    }
    
    func verbose(message: String) {
        if Logger.logMode == .verbose {
            let timestamp = NSDate().timeIntervalSince1970
            print("[\(timestamp)]: \(message)")
        }
    }
}

func log(message: String) {
    logger.log(message: message)
}

func verbose(message: String) {
    logger.verbose(message: message)
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
