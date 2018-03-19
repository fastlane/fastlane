protocol DeliverfileProtocol: class {
  var username: String { get }
  var appIdentifier: String? { get }
  var app: String { get }
  var editLive: Bool { get }
  var ipa: String? { get }
  var pkg: String? { get }
  var platform: String { get }
  var metadataPath: String? { get }
  var screenshotsPath: String? { get }
  var skipBinaryUpload: Bool { get }
  var useLiveVersion: Bool { get }
  var skipScreenshots: Bool { get }
  var appVersion: String? { get }
  var skipMetadata: Bool { get }
  var skipAppVersionUpdate: Bool { get }
  var force: Bool { get }
  var submitForReview: Bool { get }
  var rejectIfPossible: Bool { get }
  var automaticRelease: Bool { get }
  var autoReleaseDate: String? { get }
  var phasedRelease: Bool { get }
  var priceTier: String? { get }
  var buildNumber: String? { get }
  var appRatingConfigPath: String? { get }
  var submissionInformation: String? { get }
  var teamId: String? { get }
  var teamName: String? { get }
  var devPortalTeamId: String? { get }
  var devPortalTeamName: String? { get }
  var itcProvider: String? { get }
  var overwriteScreenshots: Bool { get }
  var runPrecheckBeforeSubmit: Bool { get }
  var precheckDefaultRuleLevel: String { get }
  var appIcon: String? { get }
  var appleWatchAppIcon: String? { get }
  var copyright: String? { get }
  var primaryCategory: String? { get }
  var secondaryCategory: String? { get }
  var primaryFirstSubCategory: String? { get }
  var primarySecondSubCategory: String? { get }
  var secondaryFirstSubCategory: String? { get }
  var secondarySecondSubCategory: String? { get }
  var tradeRepresentativeContactInformation: [String : Any]? { get }
  var appReviewInformation: [String : Any]? { get }
  var description: String? { get }
  var name: String? { get }
  var subtitle: [String : Any]? { get }
  var keywords: [String : Any]? { get }
  var promotionalText: [String : Any]? { get }
  var releaseNotes: String? { get }
  var privacyUrl: String? { get }
  var supportUrl: String? { get }
  var marketingUrl: String? { get }
  var languages: [String]? { get }
  var ignoreLanguageDirectoryValidation: Bool { get }
  var precheckIncludeInAppPurchases: Bool { get }
}

extension DeliverfileProtocol {
  var username: String { return "" }
  var appIdentifier: String? { return nil }
  var app: String { return "" }
  var editLive: Bool { return false }
  var ipa: String? { return nil }
  var pkg: String? { return nil }
  var platform: String { return "ios" }
  var metadataPath: String? { return nil }
  var screenshotsPath: String? { return nil }
  var skipBinaryUpload: Bool { return false }
  var useLiveVersion: Bool { return false }
  var skipScreenshots: Bool { return false }
  var appVersion: String? { return nil }
  var skipMetadata: Bool { return false }
  var skipAppVersionUpdate: Bool { return false }
  var force: Bool { return false }
  var submitForReview: Bool { return false }
  var rejectIfPossible: Bool { return false }
  var automaticRelease: Bool { return false }
  var autoReleaseDate: String? { return nil }
  var phasedRelease: Bool { return false }
  var priceTier: String? { return nil }
  var buildNumber: String? { return nil }
  var appRatingConfigPath: String? { return nil }
  var submissionInformation: String? { return nil }
  var teamId: String? { return nil }
  var teamName: String? { return nil }
  var devPortalTeamId: String? { return nil }
  var devPortalTeamName: String? { return nil }
  var itcProvider: String? { return nil }
  var overwriteScreenshots: Bool { return false }
  var runPrecheckBeforeSubmit: Bool { return true }
  var precheckDefaultRuleLevel: String { return "warn" }
  var appIcon: String? { return nil }
  var appleWatchAppIcon: String? { return nil }
  var copyright: String? { return nil }
  var primaryCategory: String? { return nil }
  var secondaryCategory: String? { return nil }
  var primaryFirstSubCategory: String? { return nil }
  var primarySecondSubCategory: String? { return nil }
  var secondaryFirstSubCategory: String? { return nil }
  var secondarySecondSubCategory: String? { return nil }
  var tradeRepresentativeContactInformation: [String : Any]? { return nil }
  var appReviewInformation: [String : Any]? { return nil }
  var description: String? { return nil }
  var name: String? { return nil }
  var subtitle: [String : Any]? { return nil }
  var keywords: [String : Any]? { return nil }
  var promotionalText: [String : Any]? { return nil }
  var releaseNotes: String? { return nil }
  var privacyUrl: String? { return nil }
  var supportUrl: String? { return nil }
  var marketingUrl: String? { return nil }
  var languages: [String]? { return nil }
  var ignoreLanguageDirectoryValidation: Bool { return false }
  var precheckIncludeInAppPurchases: Bool { return true }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.3]
