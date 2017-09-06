//
//  CommandFileProtocol.swift
//  SwiftRubyRPC
//
//  Created by Joshua Liebowitz on 8/4/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

public protocol LaneFileProtocol: class {
    var fastlaneVersion: String { get }
    var environmentVariables: EnvironmentVariables { get }

    static func runLane(named: String)

    func recordLaneDescriptions()
    func beforeAll()
    func afterAll(currentLane: String)
    func onError(currentLane: String, errorInfo: String)
}

public extension LaneFileProtocol {
    public var fastlaneVersion: String { return "" } // default "" because that means any is fine
    public func beforeAll() { } // no op by default
    public func afterAll(currentLane: String) { } // no op by default
    public func onError(currentLane: String, errorInfo: String) {} // no op by default
    public func recordLaneDescriptions() { } // no op by default
}

public class LaneFile: NSObject, LaneFileProtocol {
    public var environmentVariables: EnvironmentVariables = EnvironmentVariables.instance

//    private static let laneQueue = DispatchQueue(label: "laneQueue")

    public private(set) static var fastfileInstance: LaneFile?

    private var laneDescriptionMapping: [Selector : String] = [:]

    // Called before any lane is executed.
    private func setupAllTheThings() {
        // Step 1, add lange descriptions
        recordLaneDescriptions()

        // Step 2, send over environment variables to ruby process if we have them
        if self.environmentVariables.variables.count > 0 {
            _ = runner.executeCommand(self.environmentVariables)
        }

        // Step 3, run beforeAll() function
        beforeAll()
    }

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
            let currentFastfileInstance: LaneFile? = fastfileAsNSObjectType.init() as? LaneFile
            self.fastfileInstance = currentFastfileInstance
        }

        guard let fastfileInstance: LaneFile = self.fastfileInstance else {
            log(message: "Unable to instantiate class named: \(self.className())")
            fatalError()
        }

        // call all methods that need to be called before we start calling lanes
        fastfileInstance.setupAllTheThings()

        let currentLanes = self.lanes
        let lowerCasedLaneRequested = named.lowercased()

        guard let laneMethod = currentLanes[lowerCasedLaneRequested] else {
            log(message: "unable to find lane named: \(named)")
            fatalError()
        }

        // We need to catch all possible errors here and display a nice message
        _ = fastfileInstance.perform(NSSelectorFromString(laneMethod))

//        if error
//        fastfileInstance.onError(currentLane: named, errorInfo: <#T##String#>)
//        end

        // only call on success
        fastfileInstance.afterAll(currentLane: named)
    }

    func addLaneDescription(lane: Selector, _ description: String) {
        if laneDescriptionMapping[lane] != nil {
            fatalError("Unable to add lane description for lane: \(lane) (\(description))\nbecause it already exists")
        }
        laneDescriptionMapping[lane] = description
    }
}
