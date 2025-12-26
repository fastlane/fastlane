//
//  FastlaneTrainerExampleUITests.swift
//  FastlaneTrainerExampleUITests
//
//  Created by Olivier Halligon on 22/02/2025.
//

import XCTest

final class FastlaneTrainerExampleUITests: XCTestCase {
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    
    // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    
    // Always start with a fresh state
    let app = XCUIApplication()
    app.launchArguments = ["--uitesting"]
    app.launchEnvironment = ["UITEST_MODE": "1"]
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  @MainActor
  func testBasicNavigation() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Navigate through tabs
    app.tabBars.buttons["Settings"].tap()
    XCTAssertTrue(app.navigationBars["Settings"].exists)
    
    app.tabBars.buttons["Home"].tap()
    XCTAssertTrue(app.navigationBars["Home"].exists)
    
    // Test navigation stack
    app.buttons["Details"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Details"].exists)
    
    // Navigate back
    app.navigationBars.buttons["Back"].tap()
    XCTAssertTrue(app.navigationBars["Home"].exists)
  }
  
  @MainActor
  func testTextInputAndValidation() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Find and tap the text input field
    let textField = app.textFields["searchField"]
    textField.tap()
    
    // Type some text
    textField.typeText("Test Input")
    
    // Verify the text was entered
    XCTAssertEqual(textField.value as? String, "Test Input")
    
    // Clear text using the clear button
    app.buttons["clearText"].tap()
    XCTAssertEqual(textField.value as? String, "")
    
    // Test input validation
    textField.typeText("!@#")
    XCTAssertTrue(app.staticTexts["Invalid input"].exists)
  }
  
  @MainActor
  func testAlertHandling() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Trigger an alert
    app.buttons["showAlert"].tap()
    
    // Verify alert appears
    let alert = app.alerts.firstMatch
    XCTAssertTrue(alert.waitForExistence(timeout: 5))
    
    // Verify alert content
    XCTAssertTrue(alert.staticTexts["Alert Title"].exists)
    XCTAssertTrue(alert.staticTexts["Alert Message"].exists)
    
    // Handle different alert buttons
    alert.buttons["OK"].tap()
    
    // Verify alert is dismissed
    XCTAssertFalse(alert.exists)
  }
  
  @MainActor
  func testGesturesAndInteractions() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Test swipe gesture
    let element = app.cells.firstMatch
    element.swipeLeft()
    
    // Verify swipe action buttons appear
    XCTAssertTrue(app.buttons["Delete"].exists)
    
    // Test pull to refresh
    app.scrollViews.firstMatch.swipeDown()
    
    // Test pinch gesture
    let image = app.images.firstMatch
    image.pinch(withScale: 2, velocity: 1)
    
    // Test long press
    element.press(forDuration: 2.0)
    XCTAssertTrue(app.menus.firstMatch.exists)
  }
  
  @MainActor
  func testAccessibilityAndScreenshots() throws {
    let app = XCUIApplication()
    app.launch()
    
    // Verify accessibility labels
    let button = app.buttons["Add Item"]
    XCTAssertTrue(button.exists)
    XCTAssertEqual(button.label, "Add Item")
    
    // Take a screenshot
    let screenshot = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.lifetime = .keepAlways
    add(attachment)
    
    // Test VoiceOver elements
    let header = app.staticTexts["Main Header"]
    XCTAssertTrue(header.exists)
    XCTAssertEqual(header.value as? String, "Main Header")
    
    // Verify accessibility traits
    XCTAssertTrue(button.isEnabled)
  }
  
  @MainActor
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      // This measures how long it takes to launch your application.
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}
