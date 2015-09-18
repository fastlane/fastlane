describe Gym do
  describe Gym::PackageCommandGeneratorXcode7 do
    it "works with the example project with no additional parameters" do
      options = { project: "./examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      result = Gym::PackageCommandGeneratorXcode7.generate
      expect(result).to eq([
        "/usr/bin/xcrun xcodebuild -exportArchive",
        "-exportOptionsPlist '#{Gym::PackageCommandGeneratorXcode7.config_path}'",
        "-archivePath '#{Gym::BuildCommandGenerator.archive_path}'",
        "-exportPath '#{Gym::BuildCommandGenerator.build_path}'",
        ""
      ])
    end

    it "generates a valid plist file we need" do
      options = { project: "./examples/standard/Example.xcodeproj" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      result = Gym::PackageCommandGeneratorXcode7.generate
      config_path = Gym::PackageCommandGeneratorXcode7.config_path

      require 'plist'
      expect(Plist.parse_xml(config_path)).to eq({
        'method' => "app-store",
        'uploadBitcode' => false,
        'uploadSymbols' => true
      })
    end
  end
end
