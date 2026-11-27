//
//  ExampleMacOSUITests.swift
//  ExampleMacOSUITests
//
//  Created by Alexander Semenov on 1/19/17.
//

import XCTest

class ExampleMacOSUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        MainActor.assumeIsolated {
            let app = XCUIApplication()
            setupSnapshot(app)
            app.launch()
        }
    }

    @MainActor
    func testExample() {
        snapshot("0Launch")
    }

}
