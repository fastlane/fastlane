protocol MatchfileProtocol: class {
  var gitUrl: String { get }
  var gitBranch: String { get }
  var type: String { get }
  var appIdentifier: [String] { get }
  var username: String { get }
  var keychainName: String { get }
  var keychainPassword: String? { get }
  var readonly: Bool { get }
  var teamId: String? { get }
  var gitFullName: String? { get }
  var gitUserEmail: String? { get }
  var teamName: String? { get }
  var verbose: Bool { get }
  var force: Bool { get }
  var skipConfirmation: Bool { get }
  var shallowClone: Bool { get }
  var cloneBranchDirectly: Bool { get }
  var workspace: String? { get }
  var forceForNewDevices: Bool { get }
  var skipDocs: Bool { get }
  var platform: String { get }
  var templateName: String? { get }
}

extension MatchfileProtocol {
  var gitUrl: String { return "" }
  var gitBranch: String { return "master" }
  var type: String { return "development" }
  var appIdentifier: [String] { return [] }
  var username: String { return "" }
  var keychainName: String { return "login.keychain" }
  var keychainPassword: String? { return nil }
  var readonly: Bool { return false }
  var teamId: String? { return nil }
  var gitFullName: String? { return nil }
  var gitUserEmail: String? { return nil }
  var teamName: String? { return nil }
  var verbose: Bool { return false }
  var force: Bool { return false }
  var skipConfirmation: Bool { return false }
  var shallowClone: Bool { return false }
  var cloneBranchDirectly: Bool { return false }
  var workspace: String? { return nil }
  var forceForNewDevices: Bool { return false }
  var skipDocs: Bool { return false }
  var platform: String { return "ios" }
  var templateName: String? { return nil }
}


// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.1]
