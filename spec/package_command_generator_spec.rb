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
        "",
        "; rm -rf /tmp/PackageApplication4Gym"
      ])
    end
  end
end
