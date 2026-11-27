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
end
