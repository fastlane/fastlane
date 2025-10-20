// SocketClient.swift
// Copyright (c) 2025 FastlaneTools

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Dispatch
import Foundation

public enum SocketClientResponse: Error {
    case alreadyClosedSockets
    case malformedRequest
    case malformedResponse
    case serverError
    case clientInitiatedCancelAcknowledged
    case commandTimeout(seconds: Int)
    case connectionFailure
    case success(returnedObject: String?, closureArgumentValue: String?)
}

class SocketClient: NSObject {
    enum SocketStatus {
        case ready
        case closed
    }

    static let connectTimeoutSeconds = 2
    static let defaultCommandTimeoutSeconds = 10800 // 3 hours
    static let doneToken = "done" // TODO: remove these
    static let cancelToken = "cancelFastlaneRun"

    fileprivate var inputStream: InputStream!
    fileprivate var outputStream: OutputStream!
    fileprivate var cleaningUpAfterDone = false
    fileprivate let dispatchGroup = DispatchGroup()
    fileprivate let readSemaphore = DispatchSemaphore(value: 1)
    fileprivate let writeSemaphore = DispatchSemaphore(value: 1)
    fileprivate let commandTimeoutSeconds: Int

    private let writeQueue: DispatchQueue
    private let readQueue: DispatchQueue
    private let streamQueue: DispatchQueue
    private let host: String
    private let port: UInt32

    let maxReadLength = 65536 // max for ipc on 10.12 is kern.ipc.maxsockbuf: 8388608 ($sysctl kern.ipc.maxsockbuf)

    private(set) weak var socketDelegate: SocketClientDelegateProtocol?

    public private(set) var socketStatus: SocketStatus

    // localhost only, this prevents other computers from connecting
    init(host: String = "localhost", port: UInt32 = 2000, commandTimeoutSeconds: Int = defaultCommandTimeoutSeconds, socketDelegate: SocketClientDelegateProtocol) {
        self.host = host
        self.port = port
        self.commandTimeoutSeconds = commandTimeoutSeconds
        readQueue = DispatchQueue(label: "readQueue", qos: .background, attributes: .concurrent)
        writeQueue = DispatchQueue(label: "writeQueue", qos: .background, attributes: .concurrent)
        streamQueue = DispatchQueue.global(qos: .background)
        socketStatus = .closed
        self.socketDelegate = socketDelegate
        super.init()
    }

    func connectAndOpenStreams() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        streamQueue.sync {
            CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, self.host as CFString, self.port, &readStream, &writeStream)

            self.inputStream = readStream!.takeRetainedValue()
            self.outputStream = writeStream!.takeRetainedValue()

            self.inputStream.delegate = self
            self.outputStream.delegate = self

            self.inputStream.schedule(in: .main, forMode: .defaultRunLoopMode)
            self.outputStream.schedule(in: .main, forMode: .defaultRunLoopMode)
        }

        dispatchGroup.enter()
        readQueue.sync {
            self.inputStream.open()
        }

        dispatchGroup.enter()
        writeQueue.sync {
            self.outputStream.open()
        }

        let secondsToWait = DispatchTimeInterval.seconds(SocketClient.connectTimeoutSeconds)
        let connectTimeout = DispatchTime.now() + secondsToWait

        let timeoutResult = dispatchGroup.wait(timeout: connectTimeout)
        let failureMessage = "Couldn't connect to ruby process within: \(SocketClient.connectTimeoutSeconds) seconds"

        let success = testDispatchTimeoutResult(timeoutResult, failureMessage: failureMessage, timeToWait: secondsToWait)

        guard success else {
            socketDelegate?.commandExecuted(serverResponse: .connectionFailure) { _ in }
            return
        }

        socketStatus = .ready
        socketDelegate?.connectionsOpened()
    }

    public func send(rubyCommand: RubyCommandable) {
        verbose(message: "sending: \(rubyCommand.json)")
        send(string: rubyCommand.json)
        writeSemaphore.signal()
    }

    public func sendComplete() {
        closeSession(sendAbort: true)
    }

    private func testDispatchTimeoutResult(_ timeoutResult: DispatchTimeoutResult, failureMessage: String, timeToWait: DispatchTimeInterval) -> Bool {
        switch timeoutResult {
        case .success:
            return true
        case .timedOut:
            log(message: "Timeout: \(failureMessage)")

            if case let .seconds(seconds) = timeToWait {
                socketDelegate?.commandExecuted(serverResponse: .commandTimeout(seconds: seconds)) { _ in }
            }
            return false
        }
    }

    private func stopInputSession() {
        inputStream.close()
    }

    private func stopOutputSession() {
        outputStream.close()
    }

    private func sendThroughQueue(string: String) {
        let data = string.data(using: .utf8)!
        data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
            if let buffer = buffer.baseAddress {
                self.outputStream.write(buffer.assumingMemoryBound(to: UInt8.self), maxLength: data.count)
            }
        }
    }

    private func privateSend(string: String) {
        writeQueue.sync {
            writeSemaphore.wait()
            self.sendThroughQueue(string: string)
            writeSemaphore.signal()
            let timeoutSeconds = self.cleaningUpAfterDone ? 1 : self.commandTimeoutSeconds
            let timeToWait = DispatchTimeInterval.seconds(timeoutSeconds)
            let commandTimeout = DispatchTime.now() + timeToWait
            let timeoutResult = writeSemaphore.wait(timeout: commandTimeout)

            _ = self.testDispatchTimeoutResult(timeoutResult, failureMessage: "Ruby process didn't return after: \(SocketClient.connectTimeoutSeconds) seconds", timeToWait: timeToWait)
        }
    }

    private func send(string: String) {
        guard !cleaningUpAfterDone else {
            // This will happen after we abort if there are commands waiting to be executed
            // Need to check state of SocketClient in command runner to make sure we can accept `send`
            socketDelegate?.commandExecuted(serverResponse: .alreadyClosedSockets) { _ in }
            return
        }

        if string == SocketClient.doneToken {
            cleaningUpAfterDone = true
        }

        privateSend(string: string)
    }

    func closeSession(sendAbort: Bool = true) {
        socketStatus = .closed

        stopInputSession()

        if sendAbort {
            send(rubyCommand: ControlCommand(commandType: .done))
        }

        stopOutputSession()
        socketDelegate?.connectionsClosed()
    }

    public func enter() {
        dispatchGroup.enter()
    }

    public func leave() {
        readSemaphore.signal()
        writeSemaphore.signal()
    }
}

extension SocketClient: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard !cleaningUpAfterDone else {
            // Still getting response from server even though we are done.
            // No big deal, we're closing the streams anyway.
            // That being said, we need to balance out the dispatchGroups
            dispatchGroup.leave()
            return
        }

        if aStream === inputStream {
            switch eventCode {
            case Stream.Event.openCompleted:
                dispatchGroup.leave()

            case Stream.Event.errorOccurred:
                verbose(message: "input stream error occurred")
                closeSession(sendAbort: true)

            case Stream.Event.hasBytesAvailable:
                read()

            case Stream.Event.endEncountered:
                // nothing special here
                break

            case Stream.Event.hasSpaceAvailable:
                // we don't care about this
                break

            default:
                verbose(message: "input stream caused unrecognized event: \(eventCode)")
            }

        } else if aStream === outputStream {
            switch eventCode {
            case Stream.Event.openCompleted:
                dispatchGroup.leave()

            case Stream.Event.errorOccurred:
                // probably safe to close all the things because Ruby already disconnected
                verbose(message: "output stream received error")

            case Stream.Event.endEncountered:
                // nothing special here
                break

            case Stream.Event.hasSpaceAvailable:
                // we don't care about this
                break

            default:
                verbose(message: "output stream caused unrecognized event: \(eventCode)")
            }
        }
    }

    func read() {
        readQueue.sync {
            self.readSemaphore.wait()
            var buffer = [UInt8](repeating: 0, count: maxReadLength)
            var output = ""
            while self.inputStream!.hasBytesAvailable {
                let bytesRead: Int = inputStream!.read(&buffer, maxLength: buffer.count)
                if bytesRead >= 0 {
                    guard let read = String(bytes: buffer[..<bytesRead], encoding: .utf8) else {
                        fatalError("Unable to decode bytes from buffer \(buffer[..<bytesRead])")
                    }
                    output.append(contentsOf: read)
                } else {
                    verbose(message: "Stream read() error")
                }
            }
            self.processResponse(string: output)
            readSemaphore.signal()
        }
    }

    func handleFailure(message: [String]) {
        log(message: "Encountered a problem: \(message.joined(separator: "\n"))")
        let shutdownCommand = ControlCommand(commandType: .cancel(cancelReason: .serverError))
        send(rubyCommand: shutdownCommand)
    }

    func processResponse(string: String) {
        guard !string.isEmpty else {
            socketDelegate?.commandExecuted(serverResponse: .malformedResponse) {
                self.handleFailure(message: ["empty response from ruby process"])
                $0.writeSemaphore.signal()
            }
            return
        }

        let responseString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let socketResponse = SocketResponse(payload: responseString)
        verbose(message: "response is: \(responseString)")
        switch socketResponse.responseType {
        case .clientInitiatedCancel:
            socketDelegate?.commandExecuted(serverResponse: .clientInitiatedCancelAcknowledged) {
                $0.writeSemaphore.signal()
                self.closeSession(sendAbort: false)
            }

        case let .failure(failureInformation, failureClass, failureMessage):
            LaneFile.fastfileInstance?.onError(currentLane: ArgumentProcessor(args: CommandLine.arguments).currentLane, errorInfo: failureInformation.joined(), errorClass: failureClass, errorMessage: failureMessage)
            socketDelegate?.commandExecuted(serverResponse: .serverError) {
                $0.writeSemaphore.signal()
                self.handleFailure(message: failureMessage.map { m in [m] + failureInformation } ?? failureInformation)
            }

        case let .parseFailure(failureInformation):
            socketDelegate?.commandExecuted(serverResponse: .malformedResponse) {
                $0.writeSemaphore.signal()
                self.handleFailure(message: failureInformation)
            }

        case let .readyForNext(returnedObject, closureArgumentValue):
            socketDelegate?.commandExecuted(serverResponse: .success(returnedObject: returnedObject, closureArgumentValue: closureArgumentValue)) {
                $0.writeSemaphore.signal()
            }
        }
    }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
