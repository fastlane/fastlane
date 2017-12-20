protocol ScreengrabfileProtocol: class {
  var androidHome: String? { get }
  var buildToolsVersion: String? { get }
  var locales: [String] { get }
  var clearPreviousScreenshots: Bool { get }
  var outputDirectory: String { get }
  var skipOpenSummary: Bool { get }
  var appPackageName: String { get }
  var testsPackageName: String? { get }
  var useTestsInPackages: [String]? { get }
  var useTestsInClasses: [String]? { get }
  var launchArguments: [String]? { get }
  var testInstrumentationRunner: String { get }
  var endingLocale: String { get }
  var appApkPath: String? { get }
  var testsApkPath: String? { get }
  var specificDevice: String? { get }
  var deviceType: String { get }
  var exitOnTestFailure: Bool { get }
  var reinstallApp: Bool { get }
}

extension ScreengrabfileProtocol {
  var androidHome: String? { return nil }
  var buildToolsVersion: String? { return nil }
  var locales: [String] { return ["en-US"] }
  var clearPreviousScreenshots: Bool { return false }
  var outputDirectory: String { return "fastlane/metadata/android" }
  var skipOpenSummary: Bool { return false }
  var appPackageName: String { return "" }
  var testsPackageName: String? { return nil }
  var useTestsInPackages: [String]? { return nil }
  var useTestsInClasses: [String]? { return nil }
  var launchArguments: [String]? { return nil }
  var testInstrumentationRunner: String { return "android.support.test.runner.AndroidJUnitRunner" }
  var endingLocale: String { return "en-US" }
  var appApkPath: String? { return nil }
  var testsApkPath: String? { return nil }
  var specificDevice: String? { return nil }
  var deviceType: String { return "phone" }
  var exitOnTestFailure: Bool { return true }
  var reinstallApp: Bool { return false }
}


// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.1]
