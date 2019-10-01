protocol PrecheckfileProtocol: class {

  /// The bundle identifier of your app
  var appIdentifier: String { get }

  /// Your Apple ID Username
  var username: String { get }

  /// The ID of your App Store Connect team if you're in multiple teams
  var teamId: String? { get }

  /// The name of your App Store Connect team if you're in multiple teams
  var teamName: String? { get }

  /// The default rule level unless otherwise configured
  var defaultRuleLevel: String { get }

  /// Should check in-app purchases?
  var includeInAppPurchases: Bool { get }

  /// using text indicating that your IAP is free
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
// FastlaneRunnerAPIVersion [0.9.11]
