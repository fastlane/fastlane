// For more information about this configuration visit
// https://docs.fastlane.tools/actions/gym/#gymfile

// In general, you can use the options available
// fastlane gym --help

// Remove the // in front of the line to enable the option

class Gymfile: GymfileProtocol {
  //var sdk: String { return "iphoneos9.0" }
  //var scheme: String { return "Example" }
  var outputDirectory: String { return "./" }
}
