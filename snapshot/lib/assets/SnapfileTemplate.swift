// Uncomment the lines below you want to change by removing the // in the beginning

class Snapshotfile: SnapshotfileProtocol {
    // A list of devices you want to take the screenshots from
    //var devices: [String] { return [
    //    "iPhone 6",
    //    "iPhone 6 Plus",
    //    "iPhone 5",
    //    "iPad Pro (12.9-inch)",
    //    "iPad Pro (9.7-inch)",
    //    "Apple TV 1080p",
    //    "Apple Watch Series 6 - 44mm"
    //    ]
    //}

    // locales not supported in Swift yet
    var languages: [String] { return [
        "en-US",
        "de-DE",
        "it-IT"
        ]
    }

    // The name of the scheme which contains the UI Tests
    // var scheme: String? { return "SchemeName" }

    // Where should the resulting screenshots be stored?
    // var outputDirectory: String { return "./screenshots" }

    // Clear all previously generated screenshots before creating new ones
    // var clearPreviousScreenshots: Bool { return true }

    // Choose which project/workspace to use
    // var project: String? { return "./Project.xcodeproj" }
    // var workspace: String? { return "./Project.xcworkspace" }

    // Arguments to pass to the app on launch. See https://docs.fastlane.tools/actions/snapshot/#launch-arguments
    // var launchArguments: [String] { return ["-favColor red"] }

    // For more information about all available options run
    // fastlane snapshot --help
}
