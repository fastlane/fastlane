describe Snapshot::SimulatorLauncher do
  describe "#copy_screenshots" do
    let(:launcher) { Snapshot::SimulatorLauncher.new(launcher_configuration: instance_double(Snapshot::SimulatorLauncherConfiguration)) }
    let(:output_directory) { Dir.mktmpdir("snapshot_output") }
    let(:result_bundle) { File.join(output_directory, "test_output", "de-DE", "ExampleMacOS.xcresult") }

    before do
      allow(Snapshot).to receive(:config).and_return({ devices: devices, output_directory: output_directory, scheme: "ExampleMacOS" })
      allow(launcher).to receive(:xcodebuild_log_path).and_return(__FILE__)
      allow(Snapshot::Collector).to receive(:fetch_screenshots).and_return(true)
      FileUtils.mkdir_p(result_bundle)
    end

    after { FileUtils.rm_rf(output_directory) }

    context "on macOS" do
      let(:devices) { ["Mac"] }

      it "imports the screenshots from the language's result bundle before collecting them" do
        expect(Snapshot::Collector).to receive(:import_screenshots_from_result_bundle).with(result_bundle).ordered
        expect(Snapshot::Collector).to receive(:fetch_screenshots).ordered.and_return(true)

        launcher.copy_screenshots(language: "de-DE", locale: nil, launch_args: [""])
      end
    end

    context "on simulators" do
      let(:devices) { ["iPhone 17"] }

      it "collects as before" do
        expect(Snapshot::Collector).not_to receive(:import_screenshots_from_result_bundle)

        launcher.copy_screenshots(language: "de-DE", locale: nil, launch_args: [""])
      end
    end
  end

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
