// MatchfileProtocol.swift
// Copyright (c) 2025 FastlaneTools

public protocol MatchfileProtocol: AnyObject {
    /// Define the profile type, can be appstore, adhoc, development, enterprise, developer_id, mac_installer_distribution, developer_id_installer
    var type: String { get }

    /// Create additional cert types needed for macOS installers (valid values: mac_installer_distribution, developer_id_installer)
    var additionalCertTypes: [String]? { get }

    /// Only fetch existing certificates and profiles, don't generate new ones
    var readonly: Bool { get }

    /// Create a certificate type for Xcode 11 and later (Apple Development or Apple Distribution)
    var generateAppleCerts: Bool { get }

    /// Skip syncing provisioning profiles
    var skipProvisioningProfiles: Bool { get }

    /// The bundle identifier(s) of your app (comma-separated string or array of strings)
    var appIdentifier: [String] { get }

    /// Path to your App Store Connect API Key JSON file (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file)
    var apiKeyPath: String? { get }

    /// Your App Store Connect API Key information (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-hash-option)
    var apiKey: [String: Any]? { get }

    /// Your Apple ID Username
    var username: String? { get }

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

    /// Use a bearer authorization header to access the git repo (e.g.: access to an Azure DevOps repository), usually a string in Base64
    var gitBearerAuthorization: String? { get }

    /// Use a private key to access the git repo (e.g.: access to GitHub repository via Deploy keys), usually a id_rsa named file or the contents hereof
    var gitPrivateKey: String? { get }

    /// Name of the Google Cloud Storage bucket to use
    var googleCloudBucketName: String? { get }

    /// Path to the gc_keys.json file
    var googleCloudKeysFile: String? { get }

    /// ID of the Google Cloud project to use for authentication
    var googleCloudProjectId: String? { get }

    /// Skips confirming to use the system google account
    var skipGoogleCloudAccountConfirmation: Bool { get }

    /// Name of the S3 region
    var s3Region: String? { get }

    /// S3 access key
    var s3AccessKey: String? { get }

    /// S3 secret access key
    var s3SecretAccessKey: String? { get }

    /// Name of the S3 bucket
    var s3Bucket: String? { get }

    /// Prefix to be used on all objects uploaded to S3
    var s3ObjectPrefix: String? { get }

    /// Skip encryption of all objects uploaded to S3. WARNING: only enable this on S3 buckets with sufficiently restricted permissions and server-side encryption enabled. See https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingEncryption.html
    var s3SkipEncryption: Bool { get }

    /// GitLab Project Path (i.e. 'gitlab-org/gitlab')
    var gitlabProject: String? { get }

    /// GitLab Host (i.e. 'https://gitlab.com')
    var gitlabHost: String { get }

    /// GitLab CI_JOB_TOKEN
    var jobToken: String? { get }

    /// GitLab Access Token
    var privateToken: String? { get }

    /// Keychain the items should be imported to
    var keychainName: String { get }

    /// This might be required the first time you access certificates on a new mac. For the login/default keychain this is your macOS account password
    var keychainPassword: String? { get }

    /// Renew the provisioning profiles every time you run match
    var force: Bool { get }

    /// Renew the provisioning profiles if the device count on the developer portal has changed. Ignored for profile types 'appstore' and 'developer_id'
    var forceForNewDevices: Bool { get }

    /// Include Apple Silicon Mac devices in provisioning profiles for iOS/iPadOS apps
    var includeMacInProfiles: Bool { get }

    /// Include all matching certificates in the provisioning profile. Works only for the 'development' provisioning profile type
    var includeAllCertificates: Bool { get }

    /// Select certificate by id. Useful if multiple certificates are stored in one place
    var certificateId: String? { get }

    /// Renew the provisioning profiles if the certificate count on the developer portal has changed. Works only for the 'development' provisioning profile type. Requires 'include_all_certificates' option to be 'true'
    var forceForNewCertificates: Bool { get }

    /// Disables confirmation prompts during nuke, answering them with yes
    var skipConfirmation: Bool { get }

    /// Remove certs from repository during nuke without revoking them on the developer portal
    var safeRemoveCerts: Bool { get }

    /// Skip generation of a README.md for the created git repository
    var skipDocs: Bool { get }

    /// Set the provisioning profile's platform to work with (i.e. ios, tvos, macos, catalyst)
    var platform: String { get }

    /// Enable this if you have the Mac Catalyst capability enabled and your project was created with Xcode 11.3 or earlier. Prepends 'maccatalyst.' to the app identifier for the provisioning profile mapping
    var deriveCatalystAppIdentifier: Bool { get }

    /// The name of provisioning profile template. If the developer account has provisioning profile templates (aka: custom entitlements), the template name can be found by inspecting the Entitlements drop-down while creating/editing a provisioning profile (e.g. "Apple Pay Pass Suppression Development")
    var templateName: String? { get }

    /// A custom name for the provisioning profile. This will replace the default provisioning profile name if specified
    var profileName: String? { get }

    /// Should the command fail if it was about to create a duplicate of an existing provisioning profile. It can happen due to issues on Apple Developer Portal, when profile to be recreated was not properly deleted first
    var failOnNameTaken: Bool { get }

    /// Set to true if there is no access to Apple developer portal but there are certificates, keys and profiles provided. Only works with match import action
    var skipCertificateMatching: Bool { get }

    /// Path in which to export certificates, key and profile
    var outputPath: String? { get }

    /// Skips setting the partition list (which can sometimes take a long time). Setting the partition list is usually needed to prevent Xcode from prompting to allow a cert to be used for signing
    var skipSetPartitionList: Bool { get }

    /// Force encryption to use legacy cbc algorithm for backwards compatibility with older match versions
    var forceLegacyEncryption: Bool { get }

    /// Print out extra information and all commands
    var verbose: Bool { get }
}

public extension MatchfileProtocol {
    var type: String { return "development" }
    var additionalCertTypes: [String]? { return nil }
    var readonly: Bool { return false }
    var generateAppleCerts: Bool { return true }
    var skipProvisioningProfiles: Bool { return false }
    var appIdentifier: [String] { return [] }
    var apiKeyPath: String? { return nil }
    var apiKey: [String: Any]? { return nil }
    var username: String? { return nil }
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
    var gitPrivateKey: String? { return nil }
    var googleCloudBucketName: String? { return nil }
    var googleCloudKeysFile: String? { return nil }
    var googleCloudProjectId: String? { return nil }
    var skipGoogleCloudAccountConfirmation: Bool { return false }
    var s3Region: String? { return nil }
    var s3AccessKey: String? { return nil }
    var s3SecretAccessKey: String? { return nil }
    var s3Bucket: String? { return nil }
    var s3ObjectPrefix: String? { return nil }
    var s3SkipEncryption: Bool { return false }
    var gitlabProject: String? { return nil }
    var gitlabHost: String { return "https://gitlab.com" }
    var jobToken: String? { return nil }
    var privateToken: String? { return nil }
    var keychainName: String { return "login.keychain" }
    var keychainPassword: String? { return nil }
    var force: Bool { return false }
    var forceForNewDevices: Bool { return false }
    var includeMacInProfiles: Bool { return false }
    var includeAllCertificates: Bool { return false }
    var certificateId: String? { return nil }
    var forceForNewCertificates: Bool { return false }
    var skipConfirmation: Bool { return false }
    var safeRemoveCerts: Bool { return false }
    var skipDocs: Bool { return false }
    var platform: String { return "ios" }
    var deriveCatalystAppIdentifier: Bool { return false }
    var templateName: String? { return nil }
    var profileName: String? { return nil }
    var failOnNameTaken: Bool { return false }
    var skipCertificateMatching: Bool { return false }
    var outputPath: String? { return nil }
    var skipSetPartitionList: Bool { return false }
    var forceLegacyEncryption: Bool { return false }
    var verbose: Bool { return false }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.132]
