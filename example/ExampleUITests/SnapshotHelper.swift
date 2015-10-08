//
//  SnapshotHelper.swift
//  Example
//
//  Created by Felix Krause on 10/8/15.
//  Copyright © 2015 Felix Krause. All rights reserved.
//

import Foundation
import XCTest

func setLanguage(app: XCUIApplication)
{
    let path = "/tmp/language.txt"
    
    do {
        let locale = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        app.launchArguments = ["-AppleLanguages", "(\(locale))"]
    } catch {
        print("Couldn't detect/set language...")
    }
}

func snapshot(name: String)
{
    print("snapshot: \(name)")
    XCUIApplication().pressForDuration(3.0)
}