var appIdentifier: String { return "[[APP_IDENTIFIER]]" } // The bundle identifier of your app
var appleID: String { return "[[APPLE_ID]]" } // Your Apple email address

var teamID: String { return "[[DEV_PORTAL_TEAM_ID]]" } // Developer Portal Team ID
var itcTeam: String? { return [[ITC_TEAM]] } // iTunes Connect Team ID (may be nil if no team)

// you can even provide different app identifiers, Apple IDs and team names per lane:
// More information: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Appfile.md
