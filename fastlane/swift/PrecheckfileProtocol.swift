protocol PrecheckfileProtocol: class {
  var appIdentifier: String { get }
  var username: String { get }
  var teamId: String? { get }
  var teamName: String? { get }
  var defaultRuleLevel: String { get }
  var negativeAppleSentiment: String? { get }
  var placeholderText: String? { get }
  var otherPlatforms: String? { get }
  var futureFunctionality: String? { get }
  var testWords: String? { get }
  var curseWords: String? { get }
  var customText: String? { get }
  var copyrightDate: String? { get }
  var unreachableUrls: String? { get }
}

extension PrecheckfileProtocol {
  var appIdentifier: String { return "" }
  var username: String { return "" }
  var teamId: String? { return nil }
  var teamName: String? { return nil }
  var defaultRuleLevel: String { return "error" }
  var negativeAppleSentiment: String? { return nil }
  var placeholderText: String? { return nil }
  var otherPlatforms: String? { return nil }
  var futureFunctionality: String? { return nil }
  var testWords: String? { return nil }
  var curseWords: String? { return nil }
  var customText: String? { return nil }
  var copyrightDate: String? { return nil }
  var unreachableUrls: String? { return nil }
}
