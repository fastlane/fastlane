//
//  FastlaneTrainerExampleTests.swift
//  FastlaneTrainerExampleTests
//
//  Created by Olivier Halligon on 22/02/2025.
//

import Testing
@testable import FastlaneTrainerExample
import Foundation

extension Tag {
  @Tag static var basic: Self
  @Tag static var string: Self
  @Tag static var number: Self
  @Tag static var validation: Self
  @Tag static var async: Self
  @Tag static var performance: Self
  @Tag static var ui: Self
  @Tag static var network: Self
  @Tag static var database: Self
}

/// Root test group demonstrating various Swift Testing framework capabilities
@Suite("FastlaneTrainer Tests")
struct FastlaneTrainerTests {
  @Test("Simple string validation", .tags(.basic, .string, .validation))
  func testBasicString() {
    let greeting = "Hello, FastlaneTrainer!"
    #expect(greeting.hasPrefix("Hello"))
    #expect(greeting.hasSuffix("!"))
  }

  @Test("Simple number validation", .tags(.basic, .number, .validation))
  func testBasicNumber() {
    let number = 42
    #expect(number > 0)
    #expect(number.isMultiple(of: 2))
  }

  // MARK: - Parameterized Tests

  @Test("Validate multiple strings", arguments: [
    "Hello",
    "World",
    "FastlaneTrainer"
  ])
  func testMultipleStrings(_ input: String) {
    #expect(!input.isEmpty)
    #expect(input.count < 8)
  }

  @Test("Test number ranges", arguments: [
    (min: 0, max: 10),
    (min: 10, max: 20),
    (min: 20, max: 30)
  ])
  func testNumberRanges(range: (min: Int, max: Int)) {
    let randomNumber = Int.random(in: range.min...range.max)
    #expect(randomNumber >= range.min)
    #expect(randomNumber <= range.max)
  }

  @Test(.serialized, arguments: (0..<128).map(UnicodeScalar.init).map(Character.init))
  func testName🏷️And📋ParamsUsingSome😱Unusual🤪Characters(asciiCharacter: Character) throws {
    #expect(asciiCharacter.asciiValue != nil)
    #expect(asciiCharacter.asciiValue ?? 0 > 6, "Character \(asciiCharacter) has ASCII value <= 6")
  }

  // MARK: - Nested Test Groups

  @Suite("String Operations")
  struct StringTests {
    @Test("String concatenation")
    func testConcatenation() {
      let part1 = "Hello"
      let part2 = "World"
      #expect(part1 + " " + part2 == "Hello World")
    }

    @Test("String transformations")
    func testTransformations() {
      let input = "hello"
      #expect(input.uppercased() == "HELLO")
      #expect(input.capitalized == "Hello")
    }
  }

  @Suite("Math Operations")
  struct MathTests {
    @Test("Basic arithmetic")
    func testArithmetic() {
      #expect(2 + 2 == 4)
      #expect(10 - 5 == 5)
      #expect(3 * 4 == 12)
    }
  }

  // MARK: - Async Tests

  @Test("Async operation test", .tags(.async))
  func testAsyncOperation() async throws {
    try await Task.sleep(nanoseconds: 1_000_000_000)
    #expect(true) // Verify async operation result
  }

  @Test("Multiple async operations", .tags(.async, .performance), arguments: [1, 2, 3])
  func testMultipleAsyncOperations(_ value: Int) async throws {
    try await Task.sleep(nanoseconds: UInt64(value) * 1_000_000_000)
    #expect(value > 0)
  }

  // MARK: - Skipped Tests

  @Test("Skipped test with condition", .disabled("Feature not yet implemented"))
  func testSkippedFeature() {
  }

  @Test("Conditionally skipped test")
  func testConditionalSkip() throws {
    if !ProcessInfo.processInfo.arguments.contains("enable-experimental") {
      throw TestError(message: "Experimental features not enabled")
    }
    #expect(true)
  }

  // MARK: - Tests with Setup/Teardown

  class TestContext {
    var setupComplete = false
    var cleanupComplete = false
  }

  // MARK: - Hierarchical Test Organization

  @Suite("User Management")
  struct UserTests {
    @Suite("Registration")
    struct RegistrationTests {
      @Test("Basic registration")
      func testBasicRegistration() {
        let username = "testuser"
        let password = "password123"
        #expect(username.count >= 3)
        #expect(password.count >= 8)
      }

      @Suite("Password Validation")
      struct PasswordTests {
        @Test("Password complexity")
        func testPasswordComplexity() {
          let password = "Password123!"
          #expect(password.rangeOfCharacter(from: .uppercaseLetters) != nil)
          #expect(password.rangeOfCharacter(from: .lowercaseLetters) != nil)
          #expect(password.rangeOfCharacter(from: .decimalDigits) != nil)
        }

        @Test("Password length requirements")
        func testPasswordLength() {
          let passwords = ["short", "justbarely8", "thisislongenough"]
          for password in passwords {
            #expect(password.count < 8, "Password '\(password)' is too short")
          }
        }
      }

      @Suite("Email Validation")
      struct EmailTests {
        @Test("Valid email formats")
        func testValidEmails() {
          let emails = [
            "test@example.com",
            "user.name@domain.co.uk",
            "user+label@domain.com"
          ]
          for email in emails {
            #expect(email.contains("@"))
            #expect(email.contains("."))
          }
        }
      }
    }

    @Suite("Profile Management")
    struct ProfileTests {
      @Suite("Avatar")
      struct AvatarTests {
        @Test("Avatar dimensions")
        func testAvatarDimensions() {
          let sizes = [(width: 100, height: 100),
                      (width: 200, height: 200)]
          for size in sizes {
            #expect(size.width == size.height)
            #expect(size.width >= 100)
          }
        }

        @Test("Avatar file types", arguments: ["jpg", "png", "gif"])
        func testAvatarFileTypes(_ fileType: String) {
          let allowedTypes = ["jpg", "png", "gif"]
          #expect(allowedTypes.contains(fileType))
        }
      }

      @Suite("Settings")
      struct SettingsTests {
        @Test("Privacy settings", arguments: [
          (setting: "profile", isPrivate: true),
          (setting: "email", isPrivate: true),
          (setting: "name", isPrivate: false)
        ])
        func testPrivacySettings(_ config: (setting: String, isPrivate: Bool)) {
          if config.setting == "email" {
            #expect(config.isPrivate)
          }
        }
      }
    }
  }

  @Suite("Content Management")
  struct ContentTests {
    @Suite("Posts")
    struct PostTests {
      @Suite("Creation")
      struct CreationTests {
        @Test("Post length validation")
        func testPostLength() {
          let shortPost = "Hi"
          let longPost = String(repeating: "a", count: 1000)
          #expect(shortPost.count >= 2)
          #expect(longPost.count <= 500)
        }
      }

      @Suite("Moderation")
      struct ModerationTests {
        @Test("Content filtering", arguments: [
          "normal post",
          "post with #hashtag",
          "post with @mention"
        ])
        func testContentFiltering(_ content: String) {
          if content.contains("#") {
            #expect(content.contains("hashtag"))
          }
          if content.contains("@") {
            #expect(content.contains("mention"))
          }
        }
      }
    }
  }

  // MARK: - Advanced Test Skipping Examples

  @Suite("Test Skipping Demonstrations")
  struct SkipTests {
    // Simple unconditional skip
    @Test("Unconditionally skipped test", .disabled("Feature pending implementation"))
    func testSkippedFeature() {
    }

    // Skip with platform condition
    @Test("Platform-specific test", .enabled(if: ProcessInfo.processInfo.isMacCatalystApp, "Test only runs in Catalyst"))
    func testCatalystOnly() {
      #expect(true)
    }

    // Skip based on OS version
    @Test("Version-dependent test", .enabled(if: ProcessInfo.processInfo.isOperatingSystemAtLeast(.init(majorVersion: 14, minorVersion: 0, patchVersion: 0)), "Requires iOS 14 or later"))
    func testNewOSFeature() {
      #expect(true)
    }

    @Suite("Environment-Dependent Tests")
    struct EnvironmentTests {
      // Skip based on environment variables
      @Test("CI environment test", .enabled(if: ProcessInfo.processInfo.environment["CI"] != nil, "Test only runs in CI environment"))
      func testCIOnly() {
        #expect(true)
      }

      // Skip based on configuration
      @Test("Production config test", .enabled(if: ProcessInfo.processInfo.environment["ENV"] == "production", "Test only runs in production"))
      func testProductionConfig() {
        #expect(true)
      }
    }

    @Suite("Resource-Dependent Tests")
    struct ResourceTests {
      @Test("Network-dependent test", .tags(.network))
      func testWithNetworkRequirement() throws {
        let hasNetworkAccess = checkNetworkAccess()
        if !hasNetworkAccess {
          throw TestError(message: "Test requires network access")
        }
        #expect(true)
      }

      @Test("Database test with cleanup", .tags(.database))
      func testWithDatabaseCleanup() throws {
        let dbAvailable = checkDatabaseAccess()
        if !dbAvailable {
          cleanupTestData()
          throw TestError(message: "Database not available")
        }
        #expect(true)
      }

      private func checkNetworkAccess() -> Bool {
        return false
      }

      private func checkDatabaseAccess() -> Bool {
        return false
      }

      private func cleanupTestData() {
      }
    }

    @Suite("Feature Flag Tests")
    struct FeatureFlagTests {
      // Skip based on feature flags
      @Test("Feature flag dependent tests", arguments: [
        "basic_feature",
        "premium_feature",
        "experimental_feature"
      ])
      func testFeatureFlag(_ featureFlag: String) throws {
        let flags = [
          "basic_feature": true,
          "premium_feature": false,
          "experimental_feature": false
        ]

        if let isEnabled = flags[featureFlag], !isEnabled {
          throw TestError(message: "Feature '\(featureFlag)' is not enabled")
        }

        #expect(true, "Feature '\(featureFlag)' test executed")
      }

      // Example of combining enabled condition with tags
      @Test("Premium feature test",
            .enabled(if: isFeatureEnabled("premium"), "Premium features not available"),
            .tags(.validation))
      func testPremiumFeature() {
        #expect(true)
      }
    }
  }

  private static func isFeatureEnabled(_ feature: String) -> Bool {
    return feature == "basic_feature"
  }
}

// MARK: - Helper Extensions for Testing

extension FastlaneTrainerTests {
  struct TestError: Error {
    let message: String
  }

  func simulateAsyncWork() async throws {
    try await Task.sleep(nanoseconds: 500_000_000)
  }

  // Helper function for conditional test execution
  func skipIf(_ condition: Bool, _ message: String, perform: () throws -> Void) throws {
    if condition {
      throw TestError(message: message)
    }
    try perform()
  }
}
