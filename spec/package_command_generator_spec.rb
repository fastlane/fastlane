require 'gym/xcodebuild_fixes/swift_fix'
require 'gym/xcodebuild_fixes/watchkit_fix'
require 'gym/xcodebuild_fixes/package_application_fix'

describe Gym do
  describe Gym::PackageCommandGeneratorPre7 do
    it "works with the example project with no additional parameters" do
      options = { project: "./examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      result = Gym::PackageCommandGeneratorPre7.generate
      expect(result).to eq([
        "/usr/bin/xcrun /tmp/PackageApplication4Gym -v",
        "''",
        "-o '#{Gym::PackageCommandGeneratorPre7.ipa_path}'",
        "exportFormat ipa",
        ""
      ])
    end

    it "works with the example project with no additional parameters and an apostrophe/single quote in the product name" do
      options = { project: "./examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      allow(Gym::PackageCommandGeneratorPre7).to receive(:appfile_path).and_return("Krause's App")

      result = Gym::PackageCommandGeneratorPre7.generate
      expect(result).to eq([
        "/usr/bin/xcrun /tmp/PackageApplication4Gym -v",
        "Krause\\'s\\ App",
        "-o '#{Gym::PackageCommandGeneratorPre7.ipa_path}'",
        "exportFormat ipa",
        ""
      ])
    end
  end
end
