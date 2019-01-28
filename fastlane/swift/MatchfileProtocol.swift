protocol MatchfileProtocol: class {
  var type: String { get }
  var readonly: Bool { get }
  var appIdentifier: [String] { get }
  var username: String { get }
  var teamId: String? { get }
  var teamName: String? { get }
  var storageMode: String { get }
  var gitUrl: String { get }
  var gitBranch: String { get }
  var gitFullName: String? { get }
  var gitUserEmail: String? { get }
  var shallowClone: Bool { get }
  var cloneBranchDirectly: Bool { get }
  var googleCloudBucketName: String? { get }
  var googleCloudKeysFile: String? { get }
  var googleCloudProjectId: String? { get }
  var keychainName: String { get }
  var keychainPassword: String? { get }
  var force: Bool { get }
  var forceForNewDevices: Bool { get }
  var skipConfirmation: Bool { get }
  var skipDocs: Bool { get }
  var platform: String { get }
  var templateName: String? { get }
  var outputPath: String? { get }
  var verbose: Bool { get }
}

extension MatchfileProtocol {
  var type: String { return "development" }
  var readonly: Bool { return false }
  var appIdentifier: [String] { return [] }
  var username: String { return "" }
  var teamId: String? { return nil }
  var teamName: String? { return nil }
  var storageMode: String { return "git" }
  var gitUrl: String { return "" }
  var gitBranch: String { return "master" }
  var gitFullName: String? { return nil }
  var gitUserEmail: String? { return nil }
  var shallowClone: Bool { return false }
  var cloneBranchDirectly: Bool { return false }
  var googleCloudBucketName: String? { return nil }
  var googleCloudKeysFile: String? { return nil }
  var googleCloudProjectId: String? { return nil }
  var keychainName: String { return "login.keychain" }
  var keychainPassword: String? { return nil }
  var force: Bool { return false }
  var forceForNewDevices: Bool { return false }
  var skipConfirmation: Bool { return false }
  var skipDocs: Bool { return false }
  var platform: String { return "ios" }
  var templateName: String? { return nil }
  var outputPath: String? { return nil }
  var verbose: Bool { return false }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.5]
