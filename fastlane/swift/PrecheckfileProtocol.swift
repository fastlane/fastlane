protocol PrecheckfileProtocol: class {
  var appIdentifier: String { get }
  var username: String { get }
  var teamId: String? { get }
  var teamName: String? { get }
  var defaultRuleLevel: String { get }
  var includeInAppPurchases: Bool { get }
  var freeStuffInIap: String? { get }
}

extension PrecheckfileProtocol {
  var appIdentifier: String { return "" }
  var username: String { return "" }
  var teamId: String? { return nil }
  var teamName: String? { return nil }
  var defaultRuleLevel: String { return "error" }
  var includeInAppPurchases: Bool { return true }
  var freeStuffInIap: String? { return nil }
}


// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.1]
