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
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        app.launchArguments = ["AppleLanguages '(de-DE})'", "AppleLocale 'de-DE'"]
        app.launchArguments = ["-AppleLanguages \"(de)\""]
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.

        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
