describe Gym do
  describe Gym::BuildCommandGenerator do
    it "raises an exception when project path wasn't found" do
      expect do
        Gym.config = { project: "/notExistent" }
      end.to raise_error "Could not find project at path '/notExistent'".red
    end

    it "supports additional parameters" do
      log_path = File.expand_path("~/Library/Logs/xcodebuild-ExampleProductName-Example.log")

      xcargs_hash = { DEBUG: "1", BUNDLE_NAME: "Example App" }
      xcargs = xcargs_hash.map do |k, v|
        "#{k.to_s.shellescape}=#{v.shellescape}"
      end.join ' '
      options = { project: "./examples/standard/Example.xcodeproj", sdk: "9.0", xcargs: xcargs }
      Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

      result = Gym::BuildCommandGenerator.generate
      expect(result).to eq([
        "set -o pipefail &&",
        "xcodebuild",
        "-scheme 'Example'",
        "-project './examples/standard/Example.xcodeproj'",
        "-configuration 'Release'",
        "-sdk '9.0'",
        "-destination 'generic/platform=iOS'",
        "-archivePath '#{Gym::BuildCommandGenerator.archive_path}'",
        "DEBUG=1 BUNDLE_NAME=Example\\ App",
        :archive,
        "| tee '#{log_path}' | xcpretty"
      ])
    end

    describe "Standard Example" do
      before do
        options = { project: "./examples/standard/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
      end

      it "uses the correct build command with the example project with no additional parameters" do
        log_path = File.expand_path("~/Library/Logs/xcodebuild-ExampleProductName-Example.log")

        result = Gym::BuildCommandGenerator.generate
        expect(result).to eq([
          "set -o pipefail &&",
          "xcodebuild",
          "-scheme 'Example'",
          "-project './examples/standard/Example.xcodeproj'",
          "-configuration 'Release'",
          "-destination 'generic/platform=iOS'",
          "-archivePath '#{Gym::BuildCommandGenerator.archive_path}'",
          :archive,
          "| tee '#{log_path}' | xcpretty"
        ])
      end

      it "#project_path_array" do
        result = Gym::BuildCommandGenerator.project_path_array
        expect(result).to eq(["-scheme 'Example'", "-project './examples/standard/Example.xcodeproj'"])
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
