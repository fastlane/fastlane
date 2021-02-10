// SocketResponse.swift
// Copyright (c) 2021 FastlaneTools

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

struct SocketResponse {
    enum ResponseType {
        case parseFailure(failureInformation: [String])
        case failure(failureInformation: [String])
        case readyForNext(returnedObject: String?, closureArgumentValue: String?)
        case clientInitiatedCancel

        init(statusDictionary: [String: Any]) {
            guard let status = statusDictionary["status"] as? String else {
                self = .parseFailure(failureInformation: ["Message failed to parse from Ruby server"])
                return
            }

            if status == "ready_for_next" {
                verbose(message: "ready for next")
                let returnedObject = statusDictionary["return_object"] as? String
                let closureArgumentValue = statusDictionary["closure_argument_value"] as? String
                self = .readyForNext(returnedObject: returnedObject, closureArgumentValue: closureArgumentValue)
                return

            } else if status == "cancelled" {
                self = .clientInitiatedCancel
                return

            } else if status == "failure" {
                guard let failureInformation = statusDictionary["failure_information"] as? [String] else {
                    self = .parseFailure(failureInformation: ["Ruby server indicated failure but Swift couldn't receive it"])
                    return
                }

                self = .failure(failureInformation: failureInformation)
                return
            }
            self = .parseFailure(failureInformation: ["Message status: \(status) not a supported status"])
        }
    }

    let responseType: ResponseType

    init(payload: String) {
        guard let data = SocketResponse.convertToDictionary(text: payload) else {
            responseType = .parseFailure(failureInformation: ["Unable to parse message from Ruby server"])
            return
        }

        guard case let statusDictionary? = data["payload"] as? [String: Any] else {
            responseType = .parseFailure(failureInformation: ["Payload missing from Ruby server response"])
            return
        }

        responseType = ResponseType(statusDictionary: statusDictionary)
    }
}

extension SocketResponse {
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                log(message: error.localizedDescription)
            }
        }
        return nil
    }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
