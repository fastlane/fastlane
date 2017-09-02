//
//  CommandFileProtocol.swift
//  SwiftRubyRPC
//
//  Created by Joshua Liebowitz on 8/4/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

public protocol LaneFileProtocol: class {
    static var environmentVariables: EnvironmentVariables? { get }
    static func runLane(named: String)
}

public class LaneFile: NSObject, LaneFileProtocol {

    public private(set) static var fastfileInstance: AnyObject?

    public static var lanes: [String : String] {
        var laneToMethodName: [String : String] = [:]
        var methodCount: UInt32 = 0
        let methodList = class_copyMethodList(self, &methodCount)
        for i in 0..<Int(methodCount) {
            let selName = sel_getName(method_getName(methodList![i]))

            if let selName = selName {
                let name = String(cString: selName)
                let lowercasedName = name.lowercased()
                guard lowercasedName.hasSuffix("lane") else {
                    continue
                }

                laneToMethodName[lowercasedName] = name
                let lowercasedNameNoLane = String(lowercasedName.characters.prefix(lowercasedName.characters.count - 4))
                laneToMethodName[lowercasedNameNoLane] = name
            }
        }
        return laneToMethodName
    }

    public static func runLane(named: String) {
        if self.fastfileInstance == nil {
            let fastfileType: AnyObject.Type = NSClassFromString(self.className())!
            let fastfileAsNSObjectType: NSObject.Type = fastfileType as! NSObject.Type
            let currentFastfileInstance: AnyObject = fastfileAsNSObjectType.init()
            self.fastfileInstance = currentFastfileInstance
        }

        guard let fastfileInstance = self.fastfileInstance else {
            fatalError("Unable to instantiate class named: \(self.className())")
        }

        let currentLanes = self.lanes
        let lowerCasedLaneRequested = named.lowercased()

        guard let laneMethod = currentLanes[lowerCasedLaneRequested] else {
            fatalError("unable to find lane named: \(named)")
        }

        _ = fastfileInstance.perform(NSSelectorFromString(laneMethod))
    }

    public static var environmentVariables: EnvironmentVariables? {
        return EnvironmentVariables(variableMap: ["DELIVER_USER": "test@example.com"])
    }
}
