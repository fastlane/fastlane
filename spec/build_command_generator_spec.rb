describe Gym do
  describe Gym::BuildCommandGenerator do
    it "raises an exception when project path wasn't found" do
      expect do
        Gym.config = { project: "/notExistent" }
      end.to raise_error "Could not find project at path '/notExistent'".red
    end

    it "supports additional parameters" do
      options = { project: "./example/standard/Example.xcodeproj", sdk: "9.0" }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      result = Gym::BuildCommandGenerator.generate
      expect(result).to eq([
        "set -o pipefail &&",
        "xcodebuild",
        "-scheme 'Example'",
        "-project './example/standard/Example.xcodeproj'",
        "-configuration 'Release'",
        "-sdk '9.0'",
        "-archivePath '#{Gym::BuildCommandGenerator.archive_path}'",
        :archive,
        "| xcpretty"
      ])
    end

    describe "Standard Example" do
      before do
        options = { project: "./example/standard/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
      end

      it "uses the correct build command with the example project with no additional parameters" do
        result = Gym::BuildCommandGenerator.generate
        expect(result).to eq([
          "set -o pipefail &&",
          "xcodebuild",
          "-scheme 'Example'",
          "-project './example/standard/Example.xcodeproj'",
          "-configuration 'Release'",
          "-archivePath '#{Gym::BuildCommandGenerator.archive_path}'",
          :archive,
          "| xcpretty"
        ])
      end

      it "#project_path_array" do
        result = Gym::BuildCommandGenerator.project_path_array
        expect(result).to eq(["-scheme 'Example'", "-project './example/standard/Example.xcodeproj'"])
      end

      it "#build_path" do
        result = Gym::BuildCommandGenerator.build_path
        regex = %r{Library/Developer/Xcode/Archives/\d\d\d\d\-\d\d\-\d\d}
        expect(result).to match(regex)
      end

      it "#archive_path" do
        result = Gym::BuildCommandGenerator.archive_path
        regex = %r{Library/Developer/Xcode/Archives/\d\d\d\d\-\d\d\-\d\d/ExampleProductName \d\d\d\d\-\d\d\-\d\d \d\d\.\d\d\.\d\d.xcarchive}
        expect(result).to match(regex)
      end
    end
  end
end
