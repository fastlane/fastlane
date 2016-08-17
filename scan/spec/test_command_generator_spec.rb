describe Scan do
  before(:all) do
    options = { project: "./examples/standard/app.xcodeproj" }
    config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
    @project = FastlaneCore::Project.new(config)
  end

  before(:each) do
    @valid_simulators = "== Devices ==
-- iOS 9.3 --
    iPhone 4s (238767C4-AF29-4485-878C-7011B98DCB87) (Shutdown)
    iPhone 5 (B8E05CCB-B97A-41FC-A8A8-2771711690B5) (Shutdown)
    iPhone 5s (F48E1168-110C-4EC6-805C-6B03A03CAC2D) (Shutdown)
    iPhone 6 (BD0777BE-32DC-425F-8FC6-10008F7AB814) (Shutdown)
    iPhone 6 Plus (E9F12F3C-75B9-47D0-998A-02220E1E7E9D) (Shutdown)
    iPhone 6s (70E1E92F-A292-4980-BC3C-7770C5EEFCFD) (Shutdown)
    iPhone 6s Plus (A250CEDA-5CCD-4396-B215-19AF6D0B4ADA) (Shutdown)
    iPad 2 (57344451-50CF-40E1-96FA-DFEFC1107B79) (Shutdown)
    iPad Retina (AD4384AC-3D47-4B43-B0E2-2020C41D67F5) (Shutdown)
    iPad Air (DD134998-177F-47DA-99FA-D549D9305476) (Shutdown)
    iPad Air 2 (9B54C167-21A9-4AD7-97D4-21F2F1D7EAAF) (Shutdown)
    iPad Pro (61EEEF5C-EA64-47EF-9EED-3075E983FBCD) (Shutdown)
-- tvOS 9.2 --
    Apple TV 1080p (83C3BAF8-54AD-4403-A688-D0B6E58020AF) (Shutdown)
-- watchOS 2.2 --
    Apple Watch - 38mm (779DA803-15AF-4E18-86B1-F4BF94547891) (Shutdown)
    Apple Watch - 42mm (A6371161-FEEA-46E2-9382-0DB41C85FA70) (Shutdown)
"
    FastlaneCore::Simulator.clear_cache
    response = "response"
    allow(response).to receive(:read).and_return(@valid_simulators)
    allow(Open3).to receive(:popen3).with("xcrun simctl list devices").and_yield(nil, response, nil, nil)

    allow(Scan).to receive(:project).and_return(@project)
  end

  describe Scan::TestCommandGenerator do
    it "raises an exception when project path wasn't found" do
      expect do
        options = { project: "/notExistent" }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
      end.to raise_error "Project file not found at path '/notExistent'"
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
                                     "-scheme app",
                                     "-project ./examples/standard/app.xcodeproj",
                                     "-sdk '9.0'",
                                     "-destination 'platform=iOS Simulator,id=F48E1168-110C-4EC6-805C-6B03A03CAC2D'",
                                     "-derivedDataPath '#{Scan.config[:derived_data_path]}'",
                                     "DEBUG=1 BUNDLE_NAME=Example\\ App",
                                     :build,
                                     :test
                                   ])
    end

    it "supports custom xcpretty formatter" do
      options = { formatter: "custom-formatter", project: "./examples/standard/app.xcodeproj", sdk: "9.0" }
      Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

      result = Scan::TestCommandGenerator.generate
      expect(result.last).to include(" | xcpretty -f `custom-formatter`")
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
                                       "-scheme app",
                                       "-project ./examples/standard/app.xcodeproj",
                                       "-destination 'platform=iOS Simulator,id=F48E1168-110C-4EC6-805C-6B03A03CAC2D'",
                                       "-derivedDataPath '#{Scan.config[:derived_data_path]}'",
                                       :build,
                                       :test
                                     ])
      end

      it "#project_path_array" do
        result = Scan::TestCommandGenerator.project_path_array
        expect(result).to eq(["-scheme app", "-project ./examples/standard/app.xcodeproj"])
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
                                       "-scheme app",
                                       "-project ./examples/standard/app.xcodeproj",
                                       "-destination 'platform=iOS Simulator,id=F48E1168-110C-4EC6-805C-6B03A03CAC2D'",
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
                                       "-scheme app",
                                       "-project ./examples/standard/app.xcodeproj",
                                       "-destination 'platform=iOS Simulator,id=F48E1168-110C-4EC6-805C-6B03A03CAC2D'",
                                       "-derivedDataPath '#{Scan.config[:derived_data_path]}'",
                                       "-resultBundlePath './fastlane/test_output/app.test_result'",
                                       :build,
                                       :test
                                     ])
      end
    end

    describe "Multiple devices example" do
      it "uses multiple destinations" do
        options = { project: "./examples/standard/app.xcodeproj", destination: [
          "platform=iOS Simulator,name=iPhone 6s,OS=9.3",
          "platform=iOS Simulator,name=iPad Air 2,OS=9.2"
        ] }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        result = Scan::TestCommandGenerator.generate
        expect(result).to start_with([
                                       "set -o pipefail &&",
                                       "env NSUnbufferedIO=YES xcodebuild",
                                       "-scheme app",
                                       "-project ./examples/standard/app.xcodeproj",
                                       "-destination 'platform=iOS Simulator,name=iPhone 6s,OS=9.3' " \
                                       "-destination 'platform=iOS Simulator,name=iPad Air 2,OS=9.2'",
                                       "-derivedDataPath '#{Scan.config[:derived_data_path]}'",
                                       :build,
                                       :test
                                     ])
      end

      it "uses multiple devices" do
        options = { project: "./examples/standard/app.xcodeproj", devices: [
          "iPhone 6s (9.3)",
          "iPad Air (9.3)"
        ] }
        Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)

        result = Scan::TestCommandGenerator.generate
        expect(result).to start_with([
                                       "set -o pipefail &&",
                                       "env NSUnbufferedIO=YES xcodebuild",
                                       "-scheme app",
                                       "-project ./examples/standard/app.xcodeproj",
                                       "-destination 'platform=iOS Simulator,id=70E1E92F-A292-4980-BC3C-7770C5EEFCFD' " \
                                       "-destination 'platform=iOS Simulator,id=DD134998-177F-47DA-99FA-D549D9305476'",
                                       "-derivedDataPath '#{Scan.config[:derived_data_path]}'",
                                       :build,
                                       :test
                                     ])
      end

      it "raises an error if multiple devices are specified for `device`" do
        expect do
          options = { project: "./examples/standard/app.xcodeproj", device: [
            "iPhone 6s (9.3)",
            "iPad Air (9.3)"
          ] }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end.to raise_error("'device' value must be a String! Found Array instead.")
      end

      it "raises an error if both `device` and `devices` were given" do
        expect do
          options = {
            project: "./examples/standard/app.xcodeproj",
            device: ["iPhone 6s (9.3)"],
            devices: ["iPhone 6"]
          }
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
        end.to raise_error("'device' value must be a String! Found Array instead.")
      end
    end
  end
end
