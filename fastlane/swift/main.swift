//
//  main.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 8/26/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

let args: [String] = CommandLine.arguments

// Dump the first arg which is the program name
let fastlaneArgs = stride(from: 1, to: args.count - 1, by: 2).map {
    RunnerArgument(name: args[$0], value: args[$0+1])
}

let lanes = fastlaneArgs.filter { arg in
    return arg.name.lowercased() == "lane"
}

let fastlaneArgsMinusLanes = fastlaneArgs.filter { arg in
    return arg.name.lowercased() != "lane"
}

guard lanes.count == 1 else {
    fatalError("You must have exactly one lane specified as an arg, here's what I got: \(lanes)")
}

let lane = lanes.first!
Fastfile.runLane(named: lane.value)
