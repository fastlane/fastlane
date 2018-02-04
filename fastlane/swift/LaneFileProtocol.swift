//
//  LaneFileProtocol.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 8/4/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

public protocol LaneFileProtocol: class {
    var fastlaneVersion: String { get }
    static func runLane(named: String, parameters: [String : String]) -> Bool

    func recordLaneDescriptions()
    func beforeAll()
    func afterAll(currentLane: String)
    func onError(currentLane: String, errorInfo: String)
}

public extension LaneFileProtocol {
    var fastlaneVersion: String { return "" } // default "" because that means any is fine
    func beforeAll() { } // no op by default
    func afterAll(currentLane: String) { } // no op by default
    func onError(currentLane: String, errorInfo: String) {} // no op by default
    func recordLaneDescriptions() { } // no op by default
}

@objcMembers
public class LaneFile: NSObject, LaneFileProtocol {
    private(set) static var fastfileInstance: Fastfile?

    // Called before any lane is executed.
    private func setupAllTheThings() {
        LaneFile.fastfileInstance!.beforeAll()
    }

    private static func trimLaneFromName(laneName: String) -> String {
        return String(laneName.prefix(laneName.count - 4))
    }

    private static func trimLaneWithOptionsFromName(laneName: String) -> String {
        return String(laneName.prefix(laneName.count - 12))
    }

    private static var laneFunctionNames: [String] {
        var lanes: [String] = []
        var methodCount: UInt32 = 0
        let methodList = class_copyMethodList(self, &methodCount)
        for i in 0..<Int(methodCount) {
            let selName = sel_getName(method_getName(methodList![i]))
            let name = String(cString: selName)
            let lowercasedName = name.lowercased()
            if lowercasedName.hasSuffix("lane") || lowercasedName.hasSuffix("lanewithoptions:") {
                lanes.append(name)
            }
        }
        return lanes
    }

    public static var lanes: [String : String] {
        var laneToMethodName: [String : String] = [:]
        self.laneFunctionNames.forEach { name in
            let lowercasedName = name.lowercased()
            if lowercasedName.hasSuffix("lane") {
                laneToMethodName[lowercasedName] = name
                let lowercasedNameNoLane = trimLaneFromName(laneName: lowercasedName)
                laneToMethodName[lowercasedNameNoLane] = name
            } else if lowercasedName.hasSuffix("lanewithoptions:") {
                let lowercasedNameNoOptions = trimLaneWithOptionsFromName(laneName: lowercasedName)
                laneToMethodName[lowercasedNameNoOptions] = name
                let lowercasedNameNoLane = trimLaneFromName(laneName: lowercasedNameNoOptions)
                laneToMethodName[lowercasedNameNoLane] = name
            }
        }

        return laneToMethodName
    }

    public static func loadFastfile() {
        if self.fastfileInstance == nil {
            let fastfileType: AnyObject.Type = NSClassFromString(self.className())!
            let fastfileAsNSObjectType: NSObject.Type = fastfileType as! NSObject.Type
            let currentFastfileInstance: Fastfile? = fastfileAsNSObjectType.init() as? Fastfile
            self.fastfileInstance = currentFastfileInstance
        }
    }

    public static func runLane(named: String, parameters: [String : String]) -> Bool {
        log(message: "Running lane: \(named)")
        self.loadFastfile()

        guard let fastfileInstance: Fastfile = self.fastfileInstance else {
            let message = "Unable to instantiate class named: \(self.className())"
            log(message: message)
            fatalError(message)
        }

        let currentLanes = self.lanes
        let lowerCasedLaneRequested = named.lowercased()

        guard let laneMethod = currentLanes[lowerCasedLaneRequested] else {
            let laneNames = self.laneFunctionNames.map { laneFuctionName in
                if laneFuctionName.hasSuffix("lanewithoptions:") {
                    return trimLaneWithOptionsFromName(laneName: laneFuctionName)
                } else {
                    return trimLaneFromName(laneName: laneFuctionName)
                }
            }.joined(separator: ", ")

            let message = "[!] Could not find lane '\(named)'. Available lanes: \(laneNames)"
            log(message: message)

            let shutdownCommand = ControlCommand(commandType: .cancel(cancelReason: .clientError), message: message)
            _ = runner.executeCommand(shutdownCommand)
            return false
        }

        // call all methods that need to be called before we start calling lanes
        fastfileInstance.setupAllTheThings()

        // We need to catch all possible errors here and display a nice message
        _ = fastfileInstance.perform(NSSelectorFromString(laneMethod), with: parameters)

        // only call on success
        fastfileInstance.afterAll(currentLane: named)
        log(message: "Done running lane: \(named) 🚀")
        return true
    }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
