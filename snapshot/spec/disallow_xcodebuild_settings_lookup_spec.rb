describe Snapshot do
  # Unset every option these examples rely on being unset, and both switches for the lookup guard,
  # so the developer's environment can't change the outcome
  around do |example|
    FastlaneSpec::Env.with_env_values(
      'FASTLANE_DISALLOW_XCODEBUILD_SETTINGS_LOOKUP' => nil,
      'SNAPSHOT_DISALLOW_XCODEBUILD_SETTINGS_LOOKUP' => nil,
      'SNAPSHOT_SCHEME' => nil,
      'SNAPSHOT_NAMESPACE_LOG_FILES' => nil,
      'SNAPSHOT_BUILDLOG_PATH' => nil
    ) { example.run }
  end

  let(:options) do
    {
      project: "./snapshot/example/Example.xcodeproj",
      scheme: "ExampleUITests",
      buildlog_path: Dir.mktmpdir,
      disallow_xcodebuild_settings_lookup: true
    }
  end

  before do
    allow(Snapshot).to receive(:snapfile_name).and_return("some fake snapfile")
    # The devices option checks its names against the simulators on the machine
    allow(FastlaneCore::DeviceManager).to receive(:simulators).and_return([simulator])
  end

  let(:simulator) { FastlaneCore::DeviceManager::Device.new(name: "iPhone 15", udid: "00000000-0000-0000-0000-000000000015", os_type: "iOS", os_version: "17.0", state: "Shutdown", is_simulator: true) }

  def configure(options)
    Snapshot.config = FastlaneCore::Configuration.create(Snapshot::Options.available_options, options)
  end

  describe "with build setting lookups disallowed" do
    before do
      expect(FastlaneCore::Project).not_to receive(:run_command)
    end

    it "takes screenshots on the given `devices`, naming the logs after the scheme" do
      configure(options.merge(devices: ["iPhone 15"]))

      launcher_config = Snapshot::SimulatorLauncherConfiguration.new(snapshot_config: Snapshot.config)
      simulator_launcher = Snapshot::SimulatorLauncher.new(launcher_configuration: launcher_config)

      expect(Snapshot.config[:devices]).to eq(["iPhone 15"])
      expect(File.basename(simulator_launcher.xcodebuild_log_path)).to eq("ExampleUITests.log")
      expect(File.basename(Snapshot::TestCommandGeneratorXcode8.xcodebuild_log_path)).to eq("ExampleUITests.log")
    end

    it "names `devices` when the default devices would have to be picked" do
      expect do
        configure(options)
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /To fix this, set the `devices` option/)
    end
  end

  describe "log file names when build settings can be read" do
    it "start with the project's app name" do
      configure(options.merge(devices: ["iPhone 15"], disallow_xcodebuild_settings_lookup: false))
      allow(Snapshot.project).to receive(:app_name).and_return("Example")

      expect(File.basename(Snapshot::TestCommandGeneratorXcode8.xcodebuild_log_path)).to eq("Example-ExampleUITests.log")
    end
  end
end
