//
//  These are the tests used to generate trainer/spec/fixtures/SwiftTesting.xcresult
//

import Testing
@testable import FastlaneTrainerSwiftTesting

class FastlaneTrainerSwiftTestingTests {

    @Test func topLevelShouldPass() async throws {
        #expect(true == true)
    }

    // This is a test failure in a nested class that would not be reported as such
    // without the fix contained in https://github.com/fastlane/fastlane/pull/29470
    class NestedTests {
        @Test func nestedExampleShouldFail() async throws {
            #expect(true == false)
        }
    }
}
