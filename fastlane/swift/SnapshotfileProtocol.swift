protocol SnapshotfileProtocol: class {
  var workspace: String? { get }
  var project: String? { get }
  var xcargs: String? { get }
  var xcconfig: String? { get }
  var devices: [String]? { get }
  var languages: [String] { get }
  var launchArguments: [String] { get }
  var outputDirectory: String { get }
  var outputSimulatorLogs: Bool { get }
  var iosVersion: String? { get }
  var skipOpenSummary: Bool { get }
  var skipHelperVersionCheck: Bool { get }
  var clearPreviousScreenshots: Bool { get }
  var reinstallApp: Bool { get }
  var eraseSimulator: Bool { get }
  var localizeSimulator: Bool { get }
  var appIdentifier: String? { get }
  var addPhotos: [String]? { get }
  var addVideos: [String]? { get }
  var buildlogPath: String { get }
  var clean: Bool { get }
  var testWithoutBuilding: Bool? { get }
  var configuration: String? { get }
  var xcprettyArgs: String? { get }
  var sdk: String? { get }
  var scheme: String? { get }
  var numberOfRetries: Int { get }
  var stopAfterFirstError: Bool { get }
  var derivedDataPath: String? { get }
  var testTargetName: String? { get }
  var namespaceLogFiles: String? { get }
  var concurrentSimulators: Bool { get }
}

extension SnapshotfileProtocol {
  var workspace: String? { return nil }
  var project: String? { return nil }
  var xcargs: String? { return nil }
  var xcconfig: String? { return nil }
  var devices: [String]? { return nil }
  var languages: [String] { return ["en-US"] }
  var launchArguments: [String] { return [""] }
  var outputDirectory: String { return "screenshots" }
  var outputSimulatorLogs: Bool { return false }
  var iosVersion: String? { return nil }
  var skipOpenSummary: Bool { return false }
  var skipHelperVersionCheck: Bool { return false }
  var clearPreviousScreenshots: Bool { return false }
  var reinstallApp: Bool { return false }
  var eraseSimulator: Bool { return false }
  var localizeSimulator: Bool { return false }
  var appIdentifier: String? { return nil }
  var addPhotos: [String]? { return nil }
  var addVideos: [String]? { return nil }
  var buildlogPath: String { return "~/Library/Logs/snapshot" }
  var clean: Bool { return false }
  var testWithoutBuilding: Bool? { return nil }
  var configuration: String? { return nil }
  var xcprettyArgs: String? { return nil }
  var sdk: String? { return nil }
  var scheme: String? { return nil }
  var numberOfRetries: Int { return 1 }
  var stopAfterFirstError: Bool { return false }
  var derivedDataPath: String? { return nil }
  var testTargetName: String? { return nil }
  var namespaceLogFiles: String? { return nil }
  var concurrentSimulators: Bool { return true }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.3]
