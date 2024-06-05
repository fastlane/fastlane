//
//  LaneAction.swift
//  FastlaneRunner
//
//  Created by Desislava Dimitrova on 5.06.24.
//  Copyright © 2024 Joshua Liebowitz. All rights reserved.
//

import Foundation

public protocol LaneAction {
    func run()
}

struct IncrementBuildNumber: LaneAction {
    let version: String
    
    init(@ActionBuilder _ versionFunc: () -> String) {
        self.version = versionFunc()
    }
    
    func run() {
        let ter = OptionalConfigValue<String?>.fastlaneDefault(version)
        incrementBuildNumber(buildNumber: ter)
    }
}

struct BuildApp: LaneAction {
    func run() {
        gym()
    }
}

struct UploadToTestFlight: LaneAction {
    func run() {
        pilot()
    }
}

/* More lanes here */
