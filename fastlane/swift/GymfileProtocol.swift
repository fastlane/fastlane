protocol GymfileProtocol: class {
  var workspace: String? { get }
  var project: String? { get }
  var scheme: String? { get }
  var clean: Bool { get }
  var outputDirectory: String { get }
  var outputName: String? { get }
  var configuration: String? { get }
  var silent: Bool { get }
  var codesigningIdentity: String? { get }
  var skipPackageIpa: Bool { get }
  var includeSymbols: Bool? { get }
  var includeBitcode: Bool? { get }
  var exportMethod: String? { get }
  var exportOptions: [String : Any]? { get }
  var exportXcargs: String? { get }
  var skipBuildArchive: Bool? { get }
  var skipArchive: Bool? { get }
  var skipCodesigning: Bool? { get }
  var buildPath: String? { get }
  var archivePath: String? { get }
  var derivedDataPath: String? { get }
  var resultBundle: Bool { get }
  var resultBundlePath: String? { get }
  var buildlogPath: String { get }
  var sdk: String? { get }
  var toolchain: String? { get }
  var destination: String? { get }
  var exportTeamId: String? { get }
  var xcargs: String? { get }
  var xcconfig: String? { get }
  var suppressXcodeOutput: Bool? { get }
  var disableXcpretty: Bool? { get }
  var xcprettyTestFormat: Bool? { get }
  var xcprettyFormatter: String? { get }
  var xcprettyReportJunit: String? { get }
  var xcprettyReportHtml: String? { get }
  var xcprettyReportJson: String? { get }
  var analyzeBuildTime: Bool? { get }
  var xcprettyUtf: Bool? { get }
  var skipProfileDetection: Bool { get }
}

extension GymfileProtocol {
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
  var includeSymbols: Bool? { return nil }
  var includeBitcode: Bool? { return nil }
  var exportMethod: String? { return nil }
  var exportOptions: [String : Any]? { return nil }
  var exportXcargs: String? { return nil }
  var skipBuildArchive: Bool? { return nil }
  var skipArchive: Bool? { return nil }
  var skipCodesigning: Bool? { return nil }
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
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.5]
