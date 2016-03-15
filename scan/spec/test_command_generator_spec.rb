describe Scan do
  before(:all) do
    options = { project: "./examples/standard/app.xcodeproj" }
    config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
    @project = FastlaneCore::Project.new(config)
  end
  before(:each) do
    allow(Scan).to receive(:project).and_return(@project)
  end

  describe Scan::TestCommandGenerator do
    it "raises an exception when project path wasn't found" do
      expect do
        options = { project: "/notExistent" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
      end.to raise_error "Project file not found at path '/notExistent'".red
    end

    it "supports additional parameters" do
      log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

      xcargs_hash = { DEBUG: "1", BUNDLE_NAME: "Example App" }
      xcargs = xcargs_hash.map do |k, v|
        "#{k.to_s.shellescape}=#{v.shellescape}"
      end.join ' '
      options = { project: "./examples/standard/app.xcodeproj", sdk: "9.0", xcargs: xcargs }
      Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

      result = Scan::TestCommandGenerator.generate
      expect(result).to start_with([
                                     "set -o pipefail &&",
                                     "env NSUnbufferedIO=YES xcodebuild",
                                     "-scheme 'app'",
                                     "-project './examples/standard/app.xcodeproj'",
                                     "-sdk '9.0'",
                                     "-destination '#{Scan.config[:destination]}'",
                                     "DEBUG=1 BUNDLE_NAME=Example\\ App",
                                     :build,
                                     :test
                                   ])
    end

    describe "Standard Example" do
      before do
        options = { project: "./examples/standard/app.xcodeproj" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
      end

      it "uses the correct build command with the example project with no additional parameters" do
        log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

        result = Scan::TestCommandGenerator.generate
        expect(result).to start_with([
                                       "set -o pipefail &&",
                                       "env NSUnbufferedIO=YES xcodebuild",
                                       "-scheme 'app'",
                                       "-project './examples/standard/app.xcodeproj'",
                                       "-destination '#{Scan.config[:destination]}'",
                                       :build,
                                       :test
                                     ])
      end

      it "#project_path_array" do
        result = Scan::TestCommandGenerator.project_path_array
        expect(result).to eq(["-scheme 'app'", "-project './examples/standard/app.xcodeproj'"])
      end

      it "#build_path" do
        result = Scan::TestCommandGenerator.build_path
        regex = %r{Library/Developer/Xcode/Archives/\d\d\d\d\-\d\d\-\d\d}
        expect(result).to match(regex)
      end

      it "#buildlog_path is used when provided" do
        options = { project: "./examples/standard/app.xcodeproj", buildlog_path: "/tmp/my/path" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        result = Scan::TestCommandGenerator.xcodebuild_log_path
        expect(result).to include("/tmp/my/path")
      end

      it "#buildlog_path is not used when not provided" do
        result = Scan::TestCommandGenerator.xcodebuild_log_path
        expect(result.to_s).to include("Library/Logs/scan")
      end
    end

    describe "Derived Data Example" do
      before do
        options = { project: "./examples/standard/app.xcodeproj", derived_data_path: "/tmp/my/derived_data" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
      end

      it "uses the correct build command with the example project" do
        log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

        result = Scan::TestCommandGenerator.generate
        expect(result).to start_with([
                                       "set -o pipefail &&",
                                       "env NSUnbufferedIO=YES xcodebuild",
                                       "-scheme 'app'",
                                       "-project './examples/standard/app.xcodeproj'",
                                       "-destination '#{Scan.config[:destination]}'",
                                       "-derivedDataPath '/tmp/my/derived_data'",
                                       :build,
                                       :test
                                     ])
      end
    end

    describe "Result Bundle Example" do
      it "uses the correct build command with the example project" do
        log_path = File.expand_path("~/Library/Logs/scan/app-app.log")

        options = { project: "./examples/standard/app.xcodeproj", result_bundle: true, scheme: 'app' }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        result = Scan::TestCommandGenerator.generate
        expect(result).to start_with([
                                       "set -o pipefail &&",
                                       "env NSUnbufferedIO=YES xcodebuild",
                                       "-scheme 'app'",
                                       "-project './examples/standard/app.xcodeproj'",
                                       "-destination '#{Scan.config[:destination]}'",
                                       "-resultBundlePath './fastlane/test_output/app.test_result'",
                                       :build,
                                       :test
                                     ])
      end
    end
  end
end
