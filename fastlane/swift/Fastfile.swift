// Customise this file, documentation can be found here:
// https://github.com/fastlane/fastlane/tree/master/fastlane/docs
// All available actions: https://docs.fastlane.tools/actions
// can also be listed using the `fastlane actions` command

// Change the syntax highlighting to Ruby
// All lines starting with // are ignored when running `fastlane`

// If you want to automatically update fastlane if a new version is available:
// update_fastlane

import Foundation

class Fastfile: LaneFile {
    let appleID = "myUsername@example.com"
    let appID = "my.app.id"

    // This is the minimum version number required.
    // Update this, if you use features of a newer version
    var fastlaneVersion: String { return "[[FASTLANE_VERSION]]" }

    func beforeAll() {
        // environmentVariables["SLACK_URL"] = "https://hooks.slack.com/services/..."
        cocoapods()
        carthage()
    }

    func testLane() {
        let tag = lastGitTag()
        log(message: "tag \(tag)")
    }

    func betaLane() {
        match(gitUrl: "gitUrl", appIdentifier: [appID], username: appleID)
        // Build your app - more options available
        _ = gym(scheme: "[[SCHEME]]")
        pilot(username: appleID)
        // You can also use other beta testing services here (run `fastlane actions`)
    }

    func releaseLane() {
        match(gitUrl: "gitUrl", type: "appstore", appIdentifier: [appID], username: appleID)
        // snapshot()
        _ = gym() // Build your app - more options available
        deliver(username: appleID, app: appID, force: true)
        // frameit()
    }

    // You can define as many lanes as you want

    func afterAll(currentLane: String) {
        //This block is called, only if the executed lane was successful
        //slack(
        //    message: "Successfully deployed new App Update.",
        //    slackUrl: "slackURL"
        //)
    }

    func onError(currentLane: String, errorInfo: String) {
        slack(
            message: errorInfo,
            slackUrl: "slackUrl",
            success: false
        )
    }

    // For printing out the lane details when you call $fastlane lanes
    // You'll need to annotate each lane by adding entry in recordLaneDescriptions()
    func recordLaneDescriptions() {
        addLaneDescription(lane: #selector(testLane), "Runs all the tests")
        addLaneDescription(lane: #selector(betaLane), "Submit a new Beta Build to Apple TestFlight\nThis will also make sure the profile is up-to-date")
        addLaneDescription(lane: #selector(releaseLane), "Deploy a new version to the App Store")
    }

    // More information about multiple platforms in fastlane: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
    // All available actions: https://docs.fastlane.tools/actions

    // fastlane reports which actions are used. No personal data is recorded.
    // Learn more at https://github.com/fastlane/fastlane/#metrics
}
