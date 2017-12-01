//
//  LaneFileProtocol.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 8/4/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

public protocol LaneFileProtocol: class {
    var fastlaneVersion: String { get }
    static func runLane(named: String)
    
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
    
    private(set) var laneDescriptionMapping: [Selector : String] = [:]
    
    // Called before any lane is executed.
    private func setupAllTheThings() {
        // Step 1, add lange descriptions
        (self as! Fastfile).recordLaneDescriptions()
        
        // Step 2, run beforeAll() function
        LaneFile.fastfileInstance!.beforeAll()
    }
    
    public static var lanes: [String : String] {
        var laneToMethodName: [String : String] = [:]
        var methodCount: UInt32 = 0
        let methodList = class_copyMethodList(self, &methodCount)
        for i in 0..<Int(methodCount) {
            let selName = sel_getName(method_getName(methodList![i]))
            let name = String(cString: selName)
            let lowercasedName = name.lowercased()
            guard lowercasedName.hasSuffix("lane") else {
                continue
            }
            
            laneToMethodName[lowercasedName] = name
            let lowercasedNameNoLane = String(lowercasedName.prefix(lowercasedName.count - 4))
            laneToMethodName[lowercasedNameNoLane] = name
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
    
    public static func runLane(named: String) {
        log(message: "Running lane: \(named)")
        self.loadFastfile()
        
        guard let fastfileInstance: Fastfile = self.fastfileInstance else {
            let message = "Unable to instantiate class named: \(self.className())"
            log(message: message)
            fatalError(message)
        }
        
        // call all methods that need to be called before we start calling lanes
        fastfileInstance.setupAllTheThings()
        
        let currentLanes = self.lanes
        let lowerCasedLaneRequested = named.lowercased()
        
        guard let laneMethod = currentLanes[lowerCasedLaneRequested] else {
            let message = "unable to find lane named: \(named)"
            log(message: message)
            fatalError(message)
        }
        
        // We need to catch all possible errors here and display a nice message
        _ = fastfileInstance.perform(NSSelectorFromString(laneMethod))
        
        // only call on success
        fastfileInstance.afterAll(currentLane: named)
        log(message: "Done running lane: \(named) 🚀")
    }
    
    func addLaneDescription(lane: Selector, _ description: String) {
        if laneDescriptionMapping[lane] != nil {
            fatalError("Unable to add lane description for lane: \(lane) (\(description))\nbecause it already exists")
        }
        laneDescriptionMapping[lane] = description
    }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.1]
