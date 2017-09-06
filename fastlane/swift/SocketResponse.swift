//
//  SocketResponse.swift
//  SwiftRubyRPC
//
//  Created by Joshua Liebowitz on 7/30/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

struct SocketResponse {
    enum ResponseType {
        case parseFailure(failureInformation: [String])
        case failure(failureInformation: [String])
        case readyForNext(returnedObject: String?)

        init(statusDictionary: [String : Any]) {
            guard let status = statusDictionary["status"] as? String else {
                self = .parseFailure(failureInformation: ["Message failed to parse from Ruby server"])
                return
            }

            if status == "ready_for_next" {
                let returnedObject = statusDictionary["return_object"] as? String
                self = .readyForNext(returnedObject: returnedObject)
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
            self.responseType = .parseFailure(failureInformation: ["Unable to parse message from Ruby server"])
            return
        }

        guard case let statusDictionary? = data["payload"] as? [String : Any] else {
            self.responseType = .parseFailure(failureInformation: ["Payload missing from Ruby server response"])
            return
        }

        self.responseType = ResponseType(statusDictionary: statusDictionary)
    }
}

extension SocketResponse {
    static func convertToDictionary(text: String) -> [String : Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            } catch {
                log(message: error.localizedDescription)
            }
        }
        return nil
    }
}
