// GymfileProtocol.swift
// Copyright (c) 2021 FastlaneTools

public protocol GymfileProtocol: class {
    /// Path to the workspace file
    var workspace: String? { get }

    /// Path to the project file
    var project: String? { get }

    /// The project's scheme. Make sure it's marked as `Shared`
    var scheme: String? { get }

    /// Should the project be cleaned before building it?
    var clean: Bool { get }

    /// The directory in which the ipa file should be stored in
    var outputDirectory: String { get }

    /// The name of the resulting ipa file
    var outputName: String? { get }

    /// The configuration to use when building the app. Defaults to 'Release'
    var configuration: String? { get }

    /// Hide all information that's not necessary while building
    var silent: Bool { get }

    /// The name of the code signing identity to use. It has to match the name exactly. e.g. 'iPhone Distribution: SunApps GmbH'
    var codesigningIdentity: String? { get }

    /// Should we skip packaging the ipa?
    var skipPackageIpa: Bool { get }

    /// Should we skip packaging the pkg?
    var skipPackagePkg: Bool { get }

    /// Should the ipa file include symbols?
    var includeSymbols: Bool? { get }

    /// Should the ipa file include bitcode?
    var includeBitcode: Bool? { get }

    /// Method used to export the archive. Valid values are: app-store, validation, ad-hoc, package, enterprise, development, developer-id and mac-application
    var exportMethod: String? { get }

    /// Path to an export options plist or a hash with export options. Use 'xcodebuild -help' to print the full set of available options
    var exportOptions: [String: Any]? { get }

    /// Pass additional arguments to xcodebuild for the package phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
    var exportXcargs: String? { get }

    /// Export ipa from previously built xcarchive. Uses archive_path as source
    var skipBuildArchive: Bool? { get }

    /// After building, don't archive, effectively not including -archivePath param
    var skipArchive: Bool? { get }

    /// Build without codesigning
    var skipCodesigning: Bool? { get }

    /// Platform to build when using a Catalyst enabled app. Valid values are: ios, macos
    var catalystPlatform: String? { get }

    /// Full name of 3rd Party Mac Developer Installer or Developer ID Installer certificate. Example: `3rd Party Mac Developer Installer: Your Company (ABC1234XWYZ)`
    var installerCertName: String? { get }

    /// The directory in which the archive should be stored in
    var buildPath: String? { get }

    /// The path to the created archive
    var archivePath: String? { get }

    /// The directory where built products and other derived data will go
    var derivedDataPath: String? { get }

    /// Should an Xcode result bundle be generated in the output directory
    var resultBundle: Bool { get }

    /// Path to the result bundle directory to create. Ignored if `result_bundle` if false
    var resultBundlePath: String? { get }

    /// The directory where to store the build log
    var buildlogPath: String { get }

    /// The SDK that should be used for building the application
    var sdk: String? { get }

    /// The toolchain that should be used for building the application (e.g. com.apple.dt.toolchain.Swift_2_3, org.swift.30p620160816a)
    var toolchain: String? { get }

    /// Use a custom destination for building the app
    var destination: String? { get }

    /// Optional: Sometimes you need to specify a team id when exporting the ipa file
    var exportTeamId: String? { get }

    /// Pass additional arguments to xcodebuild for the build phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS="-ObjC -lstdc++"
    var xcargs: String? { get }

    /// Use an extra XCCONFIG file to build your app
    var xcconfig: String? { get }

    /// Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path
    var suppressXcodeOutput: Bool? { get }

    /// Disable xcpretty formatting of build output
    var disableXcpretty: Bool? { get }

    /// Use the test (RSpec style) format for build output
    var xcprettyTestFormat: Bool? { get }

    /// A custom xcpretty formatter to use
    var xcprettyFormatter: String? { get }

    /// Have xcpretty create a JUnit-style XML report at the provided path
    var xcprettyReportJunit: String? { get }

    /// Have xcpretty create a simple HTML report at the provided path
    var xcprettyReportHtml: String? { get }

    /// Have xcpretty create a JSON compilation database at the provided path
    var xcprettyReportJson: String? { get }

    /// Analyze the project build time and store the output in 'culprits.txt' file
    var analyzeBuildTime: Bool? { get }

    /// Have xcpretty use unicode encoding when reporting builds
    var xcprettyUtf: Bool? { get }

    /// Do not try to build a profile mapping from the xcodeproj. Match or a manually provided mapping should be used
    var skipProfileDetection: Bool { get }

    /// Sets a custom path for Swift Package Manager dependencies
    var clonedSourcePackagesPath: String? { get }

    /// Skips resolution of Swift Package Manager dependencies
    var skipPackageDependenciesResolution: Bool { get }

    /// Prevents packages from automatically being resolved to versions other than those recorded in the `Package.resolved` file
    var disablePackageAutomaticUpdates: Bool { get }

    /// Lets xcodebuild use system's scm configuration
    var useSystemScm: Bool { get }
}

public extension GymfileProtocol {
    var workspace: String? { return nil }
    var project: String? { return nil }
    var scheme: String? { return nil }
    var clean: Bool { return false }
    var outputDirectory: String { return "." }
    var outputName: String? { return nil }
    var configuration: String? { return nil }
    var silent: Bool { return false }
    var codesigningIdentity: String? { return nil }
    var skipPackageIpa: Bool { return false }
    var skipPackagePkg: Bool { return false }
    var includeSymbols: Bool? { return nil }
    var includeBitcode: Bool? { return nil }
    var exportMethod: String? { return nil }
    var exportOptions: [String: Any]? { return nil }
    var exportXcargs: String? { return nil }
    var skipBuildArchive: Bool? { return nil }
    var skipArchive: Bool? { return nil }
    var skipCodesigning: Bool? { return nil }
    var catalystPlatform: String? { return nil }
    var installerCertName: String? { return nil }
    var buildPath: String? { return nil }
    var archivePath: String? { return nil }
    var derivedDataPath: String? { return nil }
    var resultBundle: Bool { return false }
    var resultBundlePath: String? { return nil }
    var buildlogPath: String { return "~/Library/Logs/gym" }
    var sdk: String? { return nil }
    var toolchain: String? { return nil }
    var destination: String? { return nil }
    var exportTeamId: String? { return nil }
    var xcargs: String? { return nil }
    var xcconfig: String? { return nil }
    var suppressXcodeOutput: Bool? { return nil }
    var disableXcpretty: Bool? { return nil }
    var xcprettyTestFormat: Bool? { return nil }
    var xcprettyFormatter: String? { return nil }
    var xcprettyReportJunit: String? { return nil }
    var xcprettyReportHtml: String? { return nil }
    var xcprettyReportJson: String? { return nil }
    var analyzeBuildTime: Bool? { return nil }
    var xcprettyUtf: Bool? { return nil }
    var skipProfileDetection: Bool { return false }
    var clonedSourcePackagesPath: String? { return nil }
    var skipPackageDependenciesResolution: Bool { return false }
    var disablePackageAutomaticUpdates: Bool { return false }
    var useSystemScm: Bool { return false }
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.62]
