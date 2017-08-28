//
//  CommandFileProtocol.swift
//  SwiftRubyRPC
//
//  Created by Joshua Liebowitz on 8/4/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

public protocol CommandFile {
    static var environmentVariables: EnvironmentVariables? { get }
    static var execute: () -> Void { get }
}
