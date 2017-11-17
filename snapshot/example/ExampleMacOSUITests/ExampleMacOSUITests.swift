//
//  ExampleMacOSUITests.swift
//  ExampleMacOSUITests
//
//  Created by Alexander Semenov on 1/19/17.
//  Copyright © 2017 Felix Krause. All rights reserved.
//

import XCTest

class ExampleMacOSUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testExample() {
        snapshot("0Launch")
    }

}
