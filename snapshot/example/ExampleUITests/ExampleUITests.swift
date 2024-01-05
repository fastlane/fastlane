//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by Felix Krause on 19/06/15.
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

    func testExample() {
        snapshot("0Launch")
        let tabBar = XCUIApplication().tabBars
        let secondButton = tabBar.buttons.element(boundBy: 1)

        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
        snapshot("1LandscapeLeft")

        secondButton.tap()
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeRight
        snapshot("2LandscapeRight")

        secondButton.tap()
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        snapshot("3Portrait")
    }
}
