class Matchfile: MatchfileProtocol {
    var gitUrl: String { return "[[GIT_URL]]" }
    var type: String { return "development" } // The default type, can be: appstore, adhoc, enterprise or development
    // var appIdentifier: [String] { return ["tools.fastlane.app", "tools.fastlane.app2"] }
		// cat username:String { return "user@fastlane.tools" } // Your Apple Developer Portal username
}

// For all available options run `fastlane match --help`
// Remove the // in the beginning of the line to enable the other options
