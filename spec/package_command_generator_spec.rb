describe Gym do
  describe Gym::PackageCommandGenerator do
    it "works with the example project with no additional parameters" do
      options = { project: "./examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      result = Gym::PackageCommandGenerator.generate
      expect(result).to eq([
        "/usr/bin/xcrun /tmp/PackageApplication4Gym -v",
        "''",
        "-o '#{Gym::PackageCommandGenerator.ipa_path}'",
        "exportFormat ipa",
        ""
      ])
    end

    it "works with the example project with no additional parameters and an apostrophe/single quote in the product name" do
      options = { project: "./examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      allow(Gym::PackageCommandGenerator).to receive(:appfile_path).and_return("Krause's App")

      result = Gym::PackageCommandGenerator.generate
      expect(result).to eq([
        "/usr/bin/xcrun /tmp/PackageApplication4Gym -v",
        Shellwords.escape("Krause's App"),
        "-o '#{Gym::PackageCommandGenerator.ipa_path}'",
        "exportFormat ipa",
        ""
      ])
    end
  end
end
