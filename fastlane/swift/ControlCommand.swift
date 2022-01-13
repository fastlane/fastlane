// ControlCommand.swift
// Copyright (c) 2022 FastlaneTools

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

struct ControlCommand: RubyCommandable {
    static let commandKey = "command"
    var type: CommandType { return .control }

    enum ShutdownCommandType {
        static let userMessageKey: String = "userMessage"

        enum CancelReason {
            static let reasonKey: String = "reason"
            case clientError
            case serverError

            var reasonText: String {
                switch self {
                case .clientError:
                    return "clientError"
                case .serverError:
                    return "serverError"
                }
            }
        }

        case done
        case cancel(cancelReason: CancelReason)

        var token: String {
            switch self {
            case .done:
                return "done"
            case .cancel:
                return "cancelFastlaneRun"
            }
        }
    }

    let message: String?
    let id: String = UUID().uuidString
    let shutdownCommandType: ShutdownCommandType
    var commandJson: String {
        var jsonDictionary: [String: Any] = [ControlCommand.commandKey: shutdownCommandType.token]

        if let message = message {
            jsonDictionary[ShutdownCommandType.userMessageKey] = message
        }
        if case let .cancel(reason) = shutdownCommandType {
            jsonDictionary[ShutdownCommandType.CancelReason.reasonKey] = reason.reasonText
        }

        let jsonData = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }

    init(commandType: ShutdownCommandType, message: String? = nil) {
        shutdownCommandType = commandType
        self.message = message
    }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
