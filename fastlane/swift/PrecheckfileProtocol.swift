protocol PrecheckfileProtocol: class {
  var appIdentifier: String { get }
  var username: String { get }
  var teamId: String? { get }
  var teamName: String? { get }
  var defaultRuleLevel: String { get }
}

extension PrecheckfileProtocol {
  var appIdentifier: String { return "" }
  var username: String { return "" }
  var teamId: String? { return nil }
  var teamName: String? { return nil }
  var defaultRuleLevel: String { return "error" }
}
