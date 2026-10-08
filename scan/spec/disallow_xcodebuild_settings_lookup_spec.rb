require 'scan'

describe Scan do
  # Unset every option these examples rely on being unset, and both switches for the lookup guard,
  # so the developer's environment can't change the outcome
  around do |example|
    FastlaneSpec::Env.with_env_values(
      'FASTLANE_DISALLOW_XCODEBUILD_SETTINGS_LOOKUP' => nil,
      'SCAN_DISALLOW_XCODEBUILD_SETTINGS_LOOKUP' => nil,
      'SCAN_DEVICE' => nil,
      'SCAN_DEVICES' => nil,
      'SCAN_DESTINATION' => nil,
      'SCAN_DERIVED_DATA_PATH' => nil,
      'SCAN_APP_NAME' => nil,
      'SCAN_DEPLOYMENT_TARGET_VERSION' => nil,
      'SCAN_CATALYST_PLATFORM' => nil,
      'SCAN_RESET_SIMULATOR' => nil,
      'SCAN_REINSTALL_APP' => nil,
      'SCAN_PRELAUNCH_SIMULATOR' => nil,
      'SCAN_INCLUDE_SIMULATOR_LOGS' => nil,
      'SCAN_WORKSPACE' => nil,
      'SCAN_PACKAGE_PATH' => nil,
      'SCAN_SCHEME' => nil,
      'SLACK_URL' => nil
    ) { example.run }
  end

  let(:simulator) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 15", udid: "00000000-0000-0000-0000-000000000015", os_type: "iOS", os_version: "17.0", state: "Shutdown", is_simulator: true) }

  let(:options) do
    {
      project: "./scan/examples/standard/app.xcodeproj",
      scheme: "app",
      derived_data_path: Dir.mktmpdir,
      prelaunch_simulator: false, # its default comes from FASTLANE_EXPLICIT_OPEN_SIMULATOR
      disallow_xcodebuild_settings_lookup: true
    }
  end

  before do
    allow(FastlaneCore::DeviceManager).to receive(:simulators).and_return([simulator])
  end

  def configure(options)
    Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
  end

  # scan's setup reads the Xcode version
  describe "setup with build setting lookups disallowed", requires_xcode: true do
    before do
      expect(FastlaneCore::Project).not_to receive(:run_command)
    end

    it "tests on `destination` alone without reading build settings" do
      configure(options.merge(destination: "platform=iOS Simulator,id=#{simulator.udid}"))

      expect(Scan.config[:destination]).to eq("platform=iOS Simulator,id=#{simulator.udid}")
      expect(Scan.devices).to be_nil
    end

    it "doesn't keep the simulators an earlier run picked when only `destination` is given" do
      configure(options.merge(device: "iPhone 15"))
      expect(Scan.devices).to eq([simulator])

      configure(options.merge(destination: "platform=iOS Simulator,id=00000000-0000-0000-0000-0000000000BB"))

      expect(Scan.devices).to be_nil
    end

    it "tests on `device` alone without reading build settings" do
      configure(options.merge(device: "iPhone 15"))

      expect(Scan.devices).to eq([simulator])
      expect(Scan.config[:destination]).to eq(["platform=iOS Simulator,id=#{simulator.udid}"])
    end

    it "tests on `devices` alone without reading build settings" do
      configure(options.merge(devices: ["iPhone 15"]))

      expect(Scan.devices).to eq([simulator])
    end

    { device: "iPhone 15", devices: ["iPhone 15"] }.each do |devices_option, value|
      it "tests on `destination` with `#{devices_option}` for the simulator options, without reading build settings" do
        configure(options.merge(destination: "platform=iOS Simulator,id=#{simulator.udid}", devices_option => value, reset_simulator: true))

        expect(Scan.devices).to eq([simulator])
        expect(Scan.config[:destination]).to eq("platform=iOS Simulator,id=#{simulator.udid}")
      end
    end

    it "names `device`, `devices` and `destination` when none is set" do
      expect do
        configure(options)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /To fix this, set one of the `device`, `devices` or `destination` options/)
    end

    [:reset_simulator, :reinstall_app, :prelaunch_simulator, :include_simulator_logs].each do |simulator_option|
      it "names `device` and `devices` when `#{simulator_option}` needs a simulator that `destination` alone can't give" do
        expect do
          configure(options.merge(destination: "platform=iOS Simulator,id=#{simulator.udid}", simulator_option => true))
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /Set `device` or `devices` to use `#{simulator_option}`/)
      end
    end

    it "names `derived_data_path` when it would have to be read from the build settings" do
      expect do
        configure(options.merge(device: "iPhone 15", derived_data_path: nil))
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /To fix this, set the `derived_data_path` option/)
    end

    it "names `destination` when it would have to check for Mac Catalyst" do
      expect do
        configure(options.merge(device: "iPhone 15", catalyst_platform: "macos"))
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /To fix this, set the `destination` option/)
    end
  end

  describe "the deployment target for `device` or `devices`", requires_xcode: true do
    it "isn't read from the build settings, since there is none to filter by" do
      expect(FastlaneCore::Project).not_to receive(:run_command)

      configure(options.merge(device: "iPhone 15", disallow_xcodebuild_settings_lookup: false))

      expect(Scan.devices).to eq([simulator])
    end
  end

  describe "names derived from the app name" do
    # A project whose app name is `app_name`, which is nil when build settings can't be read
    def project_named(app_name)
      instance_double(FastlaneCore::Project, app_name_if_lookup_allowed: app_name)
    end

    # A nil project is a Swift package
    def stub_config(options, project)
      allow(Scan).to receive(:config).and_return(FastlaneCore::Configuration.create(Scan::Options.available_options, options.merge(scheme: "app", buildlog_path: Dir.mktmpdir)))
      allow(Scan).to receive(:project).and_return(project)
    end

    describe "the build log" do
      def log_name(options, project)
        stub_config(options, project)
        File.basename(Scan::TestCommandGenerator.new.xcodebuild_log_path)
      end

      it "is named after `app_name` when it's set" do
        expect(log_name({ app_name: "CustomApp" }, project_named(nil))).to eq("CustomApp-app.log")
      end

      it "is named after the scheme alone when build settings can't be read" do
        expect(log_name({}, project_named(nil))).to eq("app.log")
      end

      it "is named after the scheme alone for a Swift package" do
        expect(log_name({}, nil)).to eq("app.log")
      end

      it "is named after the project's app name otherwise" do
        expect(log_name({}, project_named("ExampleApp"))).to eq("ExampleApp-app.log")
      end
    end

    describe "the Slack message" do
      before do
        allow_any_instance_of(Fastlane::Actions::SlackAction::Runner).to receive(:post_message).with(any_args)
      end

      def slack_message(options, project)
        stub_config(options.merge(slack_url: "https://slack/hook/url"), project)
        message = nil
        allow(Fastlane::Actions::SlackAction).to receive(:run) { |slack_options| message = slack_options[:message] }
        Scan::SlackPoster.new.run({ tests: 1, failures: 0 })
        message
      end

      it "names `app_name` when it's set" do
        expect(slack_message({ app_name: "CustomApp" }, project_named(nil))).to start_with("CustomApp Tests:")
      end

      it "names the scheme when build settings can't be read" do
        expect(slack_message({}, project_named(nil))).to start_with("app Tests:")
      end

      it "names the scheme for a Swift package" do
        expect(slack_message({}, nil)).to start_with("app Tests:")
      end

      it "names the project's app name otherwise" do
        expect(slack_message({}, project_named("ExampleApp"))).to start_with("ExampleApp Tests:")
      end
    end
  end
end
