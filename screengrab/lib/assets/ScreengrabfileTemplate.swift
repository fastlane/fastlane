// remove the leading "//" to uncomment lines

// For more information about all available options run
//   fastlane screengrab --help

class Screengrabfile: ScreengrabfileProtocol {
    //var appPackageName: String { return "your.app.package" }
    //var useTestsInPackages: [String] { return ["your.screenshot.tests.package"] }
    //var appApkPath: String? { return "path/to/your/app.apk" }
    //var testsApkPath: String? { return "path/to/your/tests.apk" }
    var locales: [String] { return ["en-US", "fr-FR", "it-IT"] }

    // clear all previously generated screenshots in your local output directory before creating new ones
    var clearPreviousScreenshots: Bool { return true }
}
