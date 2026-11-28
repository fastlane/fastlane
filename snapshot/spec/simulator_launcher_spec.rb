describe Snapshot::SimulatorLauncher do
  describe "#take_screenshots_simultaneously" do
    let(:launcher_config) do
      instance_double(Snapshot::SimulatorLauncherConfiguration, launch_args_set: [[""]], languages: ["en-US"], concurrent_simulators?: true, devices: devices)
    end
    let(:launcher) { Snapshot::SimulatorLauncher.new(launcher_configuration: launcher_config) }

    before do
      allow(launcher).to receive(:xcodebuild_log_path).and_return("/path/to/missing.log")
      allow(launcher).to receive(:default_number_of_simultaneous_simulators).and_return(4)
      allow(FastlaneCore::DeviceManager).to receive(:simulators).and_return([
                                                                              FastlaneCore::DeviceManager::Device.new(name: "iPhone 17", os_type: "iOS", os_version: "26.2", is_simulator: true)
                                                                            ])
    end

    context "on macOS, with concurrent simulators" do
      let(:devices) { ["Mac"] }

      it "runs the Mac in one batch" do
        expect(launcher).to receive(:launch_simultaneously).with(["Mac"], "en-US", nil, [""]).and_return(true)

        launcher.take_screenshots_simultaneously
      end
    end
  end
end
