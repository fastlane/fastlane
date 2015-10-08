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
        setLanguage(app)
        app.launch()
    }
    
    func testExample() {
        let tabBar = XCUIApplication().tabBars
        let secondButton = tabBar.buttons["Second"]

        XCUIDevice().orientation = UIDeviceOrientation.LandscapeLeft
        snapshot("yeah 1 - First Screen")
        
        secondButton.tap()
        XCUIDevice().orientation = UIDeviceOrientation.LandscapeRight
        snapshot("yeah 2 - Second Screen")

        secondButton.tap()
        XCUIDevice().orientation = UIDeviceOrientation.Portrait
        snapshot("yeah 3 - Third Screen")
    }
}
