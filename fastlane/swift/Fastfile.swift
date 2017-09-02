//
//  Fastfile.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 9/1/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

class Fastfile: LaneFile {
    func deploymentLane() {
        print("Starting deployment!")

        let isRunningInCi = isCi()

        print("Deployment Done, running in ci?: \(isRunningInCi)")
    }
}
