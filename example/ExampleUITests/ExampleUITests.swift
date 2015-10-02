//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by Felix Krause on 19/06/15.
//  Copyright © 2015 Felix Krause. All rights reserved.
//

import Foundation
import XCTest

class ExampleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        let env = NSProcessInfo.processInfo().environment
        print(env)
        print("Yo")
        
        let path = "/tmp/language.txt"
        var locale = ""
        print("Loaded up \(locale)")
        
        do {
            locale = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
        } catch {
//            TODO: crash here
        }
        
        app.launchArguments = ["-AppleLanguages", "(\(locale))"]
        
        continueAfterFailure = false

        app.launch()
    }
    
    func testExample() {
        let tabBar = XCUIApplication().tabBars
        
        let secondButton = tabBar.buttons["Second"]
        
        XCUIDevice().orientation = UIDeviceOrientation.LandscapeLeft
        
        secondButton.tap()
        
        XCUIDevice().orientation = UIDeviceOrientation.LandscapeRight
        
        secondButton.tap()
    }
    
}
