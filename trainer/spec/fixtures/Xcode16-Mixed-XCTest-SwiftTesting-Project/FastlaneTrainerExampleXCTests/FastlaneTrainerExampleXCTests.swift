//
//  FastlaneTrainerExampleXCTests.swift
//  FastlaneTrainerExampleXCTests
//
//  Created by Olivier Halligon on 22/02/2025.
//

import XCTest
@testable import FastlaneTrainerExample

final class FastlaneTrainerExampleXCTests: XCTestCase {
  // MARK: - Test Lifecycle
  
  fileprivate var systemUnderTest: Calculator!
  fileprivate var mockDataStore: MockDataStore!

  override class func setUp() {
    super.setUp()
    // Called once before all tests in the class
    print("Starting test suite execution")
  }
  
  override class func tearDown() {
    super.tearDown()
    // Called once after all tests in the class
    print("Finished test suite execution")
  }
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    // Called before each test
    systemUnderTest = Calculator()
    mockDataStore = MockDataStore()
    
    // Example of throwing setup
    guard ProcessInfo.processInfo.environment["TEST_ENV"] != nil else {
      throw XCTSkip("Tests require TEST_ENV to be set")
    }
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    // Called after each test
    systemUnderTest = nil
    mockDataStore = nil
  }
  
  // MARK: - Basic Assertions
  
  func testBasicAssertions() {
    // Boolean assertions
    XCTAssertTrue(true, "True should be true")
    XCTAssertFalse(true, "False should be false")
    
    // Equality assertions
    XCTAssertEqual(2 + 2, 4, "Basic addition")
    XCTAssertNotEqual(2 + 2, 5, "Basic addition inequality")
    
    // Nil assertions
    let optional: String? = nil
    XCTAssertNil(optional, "Optional should be nil")
    let nonOptional: String? = "value"
    XCTAssertNotNil(nonOptional, "Optional should not be nil")
    
    // Floating point comparison
    XCTAssertEqual(0.1 + 0.2, 0.3, accuracy: 0.000001, "Floating point comparison with accuracy")
  }
  
  // MARK: - Throwing Tests
  
  func testThrowingOperation() throws {
    // Test throwing operation
    XCTAssertThrowsError(try systemUnderTest.divide(10, by: 0)) { error in
      XCTAssertEqual(error as? Calculator.Error, Calculator.Error.divisionByZero)
    }
    
    // Test non-throwing operation
    XCTAssertNoThrow(try systemUnderTest.divide(10, by: 2))
    
    // Direct try with XCTAssert
    let result = try systemUnderTest.divide(10, by: 2)
    XCTAssertEqual(result, 5)
  }
  
  // MARK: - Asynchronous Testing
  
  func testAsyncOperation() async throws {
    // Test async operation with timeout
    let result = try await XCTAsyncTest {
      try await self.systemUnderTest.fetchDataAsync()
    }
    XCTAssertEqual(result, "data")
  }
  
  func testAsyncOperationWithExpectation() {
    // Traditional expectation-based async testing
    let expectation = expectation(description: "Async operation completion")
    
    systemUnderTest.fetchData { result in
      XCTAssertEqual(result, "data")
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 1.0)
  }
  
  func testMultipleExpectations() {
    let expectation1 = expectation(description: "First operation")
    let expectation2 = expectation(description: "Second operation")
    
    DispatchQueue.global().async {
      // Simulate work
      Thread.sleep(forTimeInterval: 0.1)
      expectation1.fulfill()
    }
    
    DispatchQueue.global().async {
      // Simulate work
      Thread.sleep(forTimeInterval: 0.2)
      expectation2.fulfill()
    }
    
    wait(for: [expectation1, expectation2], timeout: 1.0)
  }
  
  // MARK: - Performance Testing
  
  func testPerformance() {
    measure {
      // Code to measure
      systemUnderTest.performanceIntensiveOperation()
    }
  }
  
  func testPerformanceWithMetrics() throws {
    let metrics: [XCTMetric] = [
      XCTClockMetric(),
      XCTCPUMetric(),
      XCTMemoryMetric(),
      XCTStorageMetric()
    ]
    
    let measureOptions = XCTMeasureOptions()
    measureOptions.iterationCount = 5
    
    measure(metrics: metrics, options: measureOptions) {
      systemUnderTest.performanceIntensiveOperation()
    }
  }
  
  // MARK: - Conditional Testing
  
  func testConditionalExecution() throws {
    if !ProcessInfo.processInfo.arguments.contains("--include-slow-tests") {
      throw XCTSkip("Skipping slow tests")
    }
    
    // Slow test code here
    systemUnderTest.slowOperation()
  }
  
  func testPlatformSpecific() throws {
    #if os(iOS)
    XCTAssertTrue(UIDevice.current.userInterfaceIdiom == .phone)
    #elseif os(macOS)
    throw XCTSkip("Test only runs on iOS")
    #endif
  }
  
  // MARK: - Test Ordering
  
  func testA_FirstTest() {
    // Tests are executed alphabetically by default
    XCTAssertTrue(true)
  }
  
  func testB_SecondTest() {
    XCTAssertTrue(true)
  }
}

// MARK: - Test Helpers

private extension FastlaneTrainerExampleXCTests {
  class Calculator {
    enum Error: Swift.Error {
      case divisionByZero
    }
    
    func divide(_ a: Int, by b: Int) throws -> Int {
      guard b != 0 else { throw Error.divisionByZero }
      return a / b
    }
    
    func fetchDataAsync() async throws -> String {
      try await Task.sleep(nanoseconds: 100_000_000)
      return "data"
    }
    
    func fetchData(completion: @escaping (String) -> Void) {
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
        completion("data")
      }
    }
    
    func performanceIntensiveOperation() {
      // Simulate intensive work
      (0...1000).reduce(0, +)
    }
    
    func slowOperation() {
      Thread.sleep(forTimeInterval: 1.0)
    }
  }
  
  class MockDataStore {
    var data: [String: Any] = [:]
  }
}

// MARK: - Custom Test Extensions

extension XCTestCase {
  func XCTAsyncTest<T>(
    timeout: TimeInterval = 1.0,
    operation: @escaping () async throws -> T
  ) async throws -> T {
    try await withTimeout(timeout) {
      try await operation()
    }
  }
  
  private func withTimeout<T>(
    _ timeout: TimeInterval,
    operation: @escaping () async throws -> T
  ) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
      group.addTask {
        try await operation()
      }
      
      group.addTask {
        try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
        throw XCTSkip("Operation timed out after \(timeout) seconds")
      }
      
      let result = try await group.next()!
      group.cancelAll()
      return result
    }
  }
}
