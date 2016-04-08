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
        setupSnapshot(app)
        app.launch()
    }
    
    func testExample()
    {
        snapshot("0Launch")
        let tabBar = XCUIApplication().tabBars
        let secondButton = tabBar.buttons.elementBoundByIndex(1)

        XCUIDevice().orientation = UIDeviceOrientation.LandscapeLeft
        snapshot("1LandscapeLeft")
        
        secondButton.tap()
        XCUIDevice().orientation = UIDeviceOrientation.LandscapeRight
        snapshot("2LandscapeRight")

        secondButton.tap()
        XCUIDevice().orientation = UIDeviceOrientation.Portrait
        snapshot("3Portrait")
    }
}
