//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by Felix Krause on 19/06/15.
//

import Foundation
import XCTest

class ExampleTVUITests: XCTestCase {

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
