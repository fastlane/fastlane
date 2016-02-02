describe Gym do
  describe Gym::BuildCommandGenerator do
    it "raises an exception when project path wasn't found" do
      expect do
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, { project: "/notExistent" })
      end.to raise_error "Project file not found at path '/notExistent'"
    end

    it "supports additional parameters" do
      log_path = File.expand_path("~/Library/Logs/gym/ExampleProductName-Example.log")

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
        "-sdk '9.0'",
        "-destination 'generic/platform=iOS'",
        "-archivePath '#{Gym::BuildCommandGenerator.archive_path}'",
        "DEBUG=1 BUNDLE_NAME=Example\\ App",
        :archive,
        "| tee #{log_path.shellescape} | xcpretty"
      ])
    end

    describe "Standard Example" do
      before do
        options = { project: "./examples/standard/Example.xcodeproj" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
      end

      it "uses the correct build command with the example project with no additional parameters" do
        log_path = File.expand_path("~/Library/Logs/gym/ExampleProductName-Example.log")

        result = Gym::BuildCommandGenerator.generate
        expect(result).to eq([
          "set -o pipefail &&",
          "xcodebuild",
          "-scheme 'Example'",
          "-project './examples/standard/Example.xcodeproj'",
          "-destination 'generic/platform=iOS'",
          "-archivePath '#{Gym::BuildCommandGenerator.archive_path}'",
          :archive,
          "| tee #{log_path.shellescape} | xcpretty"
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

      it "#buildlog_path is used when provided" do
        options = { project: "./examples/standard/Example.xcodeproj", buildlog_path: "/tmp/my/path" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
        result = Gym::BuildCommandGenerator.xcodebuild_log_path
        expect(result).to include("/tmp/my/path")
      end

      it "#buildlog_path is not used when not provided" do
        result = Gym::BuildCommandGenerator.xcodebuild_log_path
        expect(result.to_s).to include("Library/Logs/gym")
      end
    end

    describe "Derived Data Example" do
      before do
        options = { project: "./examples/standard/Example.xcodeproj", derived_data_path: "/tmp/my/derived_data" }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
      end

      it "uses the correct build command with the example project" do
        log_path = File.expand_path("~/Library/Logs/gym/ExampleProductName-Example.log")

        result = Gym::BuildCommandGenerator.generate
        expect(result).to eq([
          "set -o pipefail &&",
          "xcodebuild",
          "-scheme 'Example'",
          "-project './examples/standard/Example.xcodeproj'",
          "-destination 'generic/platform=iOS'",
          "-archivePath '#{Gym::BuildCommandGenerator.archive_path}'",
          "-derivedDataPath '/tmp/my/derived_data'",
          :archive,
          "| tee #{log_path.shellescape} | xcpretty"
        ])
      end
    end

    describe "Result Bundle Example" do
      it "uses the correct build command with the example project" do
        log_path = File.expand_path("~/Library/Logs/gym/ExampleProductName-Example.log")

        options = { project: "./examples/standard/Example.xcodeproj", result_bundle: true }
        Gym.config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)

        result = Gym::BuildCommandGenerator.generate
        expect(result).to eq([
          "set -o pipefail &&",
          "xcodebuild",
          "-scheme 'Example'",
          "-project './examples/standard/Example.xcodeproj'",
          "-destination 'generic/platform=iOS'",
          "-archivePath '#{Gym::BuildCommandGenerator.archive_path}'",
          "-resultBundlePath './ExampleProductName.result'",
          :archive,
          "| tee #{log_path.shellescape} | xcpretty"
        ])
      end
    end
  end
end
