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
        
        let path = "/tmp/language.txt"
        do {
            let locale = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
            app.launchArguments = ["-AppleLanguages", "(\(locale))"]
        } catch {
//            TODO: crash here
        }
        
        continueAfterFailure = false
        app.launch()
    }
    
    func testExample() {
        let tabBar = XCUIApplication().tabBars
        
        let secondButton = tabBar.buttons["Second"]
        
        XCUIDevice().orientation = UIDeviceOrientation.LandscapeLeft
        
        snapshot("1 - First Screen")
        
        secondButton.tap()
    
        
        XCUIDevice().orientation = UIDeviceOrientation.LandscapeRight
        
        secondButton.tap()
    }
    
    func snapshot(name: String) {
        print("snapshot: \(name) (\(NSDate().timeIntervalSince1970))")
    }
    
}
