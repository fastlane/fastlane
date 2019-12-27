protocol MatchfileProtocol: class {

  /// Define the profile type, can be appstore, adhoc, development, enterprise
  var type: String { get }

  /// Only fetch existing certificates and profiles, don't generate new ones
  var readonly: Bool { get }

  /// Create a certificate type for Xcode 11 and later (Apple Development or Apple Distribution)
  var generateAppleCerts: Bool { get }

  /// Skip syncing provisioning profiles
  var skipProvisioningProfiles: Bool { get }

  /// The bundle identifier(s) of your app (comma-separated)
  var appIdentifier: [String] { get }

  /// Your Apple ID Username
  var username: String { get }

  /// The ID of your Developer Portal team if you're in multiple teams
  var teamId: String? { get }

  /// The name of your Developer Portal team if you're in multiple teams
  var teamName: String? { get }

  /// Define where you want to store your certificates
  var storageMode: String { get }

  /// URL to the git repo containing all the certificates
  var gitUrl: String { get }

  /// Specific git branch to use
  var gitBranch: String { get }

  /// git user full name to commit
  var gitFullName: String? { get }

  /// git user email to commit
  var gitUserEmail: String? { get }

  /// Make a shallow clone of the repository (truncate the history to 1 revision)
  var shallowClone: Bool { get }

  /// Clone just the branch specified, instead of the whole repo. This requires that the branch already exists. Otherwise the command will fail
  var cloneBranchDirectly: Bool { get }

  /// Use a basic authorization header to access the git repo (e.g.: access via HTTPS, GitHub Actions, etc), usually a string in Base64
  var gitBasicAuthorization: String? { get }

  /// Use a bearer authorization header to access the git repo (e.g.: access to an Azure Devops repository), usually a string in Base64
  var gitBearerAuthorization: String? { get }

  /// Name of the Google Cloud Storage bucket to use
  var googleCloudBucketName: String? { get }

  /// Path to the gc_keys.json file
  var googleCloudKeysFile: String? { get }

  /// ID of the Google Cloud project to use for authentication
  var googleCloudProjectId: String? { get }

  /// Keychain the items should be imported to
  var keychainName: String { get }

  /// This might be required the first time you access certificates on a new mac. For the login/default keychain this is your account password
  var keychainPassword: String? { get }

  /// Renew the provisioning profiles every time you run match
  var force: Bool { get }

  /// Renew the provisioning profiles if the device count on the developer portal has changed. Ignored for profile type 'appstore'
  var forceForNewDevices: Bool { get }

  /// Disables confirmation prompts during nuke, answering them with yes
  var skipConfirmation: Bool { get }

  /// Skip generation of a README.md for the created git repository
  var skipDocs: Bool { get }

  /// Set the provisioning profile's platform to work with (i.e. ios, tvos)
  var platform: String { get }

  /// The name of provisioning profile template. If the developer account has provisioning profile templates (aka: custom entitlements), the template name can be found by inspecting the Entitlements drop-down while creating/editing a provisioning profile (e.g. "Apple Pay Pass Suppression Development")
  var templateName: String? { get }

  /// Path in which to export certificates, key and profile
  var outputPath: String? { get }

  /// Print out extra information and all commands
  var verbose: Bool { get }
}

extension MatchfileProtocol {
  var type: String { return "development" }
  var readonly: Bool { return false }
  var generateAppleCerts: Bool { return true }
  var skipProvisioningProfiles: Bool { return false }
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
  var gitBasicAuthorization: String? { return nil }
  var gitBearerAuthorization: String? { return nil }
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
// FastlaneRunnerAPIVersion [0.9.12]
