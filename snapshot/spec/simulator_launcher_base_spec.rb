describe Snapshot do
  describe Snapshot::SimulatorLauncherBase do
    let(:device_udid) { "123456789" }
    let(:paths) { ['./logo.png'] }

    describe '#prepare_simulators_for_launch' do
      let(:launcher_config) do
        instance_double(
          Snapshot::SimulatorLauncherConfiguration,
          headless: headless,
          erase_simulator: false,
          localize_simulator: false,
          dark_mode: nil,
          reinstall_app: false,
          disable_slide_to_type: false
        )
      end
      let(:headless) { false }
      let(:launcher) { Snapshot::SimulatorLauncherBase.new(launcher_configuration: launcher_config) }
      let(:simulator_path) { "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" }

      before do
        allow(Snapshot).to receive(:kill_simulator)
        allow(Fastlane::Helper).to receive(:backticks)
          .with("xcrun simctl shutdown booted", print: FastlaneCore::Globals.verbose?)
          .and_return("")
        allow(Snapshot::Fixes::SimulatorZoomFix).to receive(:patch)
        allow(Snapshot::Fixes::HardwareKeyboardFix).to receive(:patch)
        allow(Snapshot::Fixes::SharedPasteboardFix).to receive(:patch)
        allow(Fastlane::Helper).to receive(:xcode_path).and_return("/Applications/Xcode.app/Contents/Developer")
      end

      it "opens the first requested simulator" do
        allow(Snapshot::TestCommandGenerator).to receive(:device_udid).with("iPhone 16 Pro").and_return(device_udid)

        expect(Fastlane::Helper).to receive(:backticks)
          .with("open -a #{simulator_path} -g --args -CurrentDeviceUDID #{device_udid}", print: FastlaneCore::Globals.verbose?)
          .and_return("")

        launcher.prepare_simulators_for_launch(["iPhone 16 Pro", "iPad Pro 13-inch (M4)"])
      end

      it "preserves the generic Simulator launch when the device cannot be resolved" do
        allow(Snapshot::TestCommandGenerator).to receive(:device_udid).with("Mac").and_return(nil)

        expect(Fastlane::Helper).to receive(:backticks)
          .with("open -a #{simulator_path} -g", print: FastlaneCore::Globals.verbose?)
          .and_return("")

        launcher.prepare_simulators_for_launch(["Mac"])
      end

      it "does not resolve or open a simulator when running headlessly" do
        allow(launcher_config).to receive(:headless).and_return(true)

        expect(Snapshot::TestCommandGenerator).not_to receive(:device_udid)
        expect(Fastlane::Helper).not_to receive(:backticks)
          .with(match(/^open /), print: FastlaneCore::Globals.verbose?)

        launcher.prepare_simulators_for_launch(["iPhone 16 Pro"])
      end
    end

    describe '#add_media' do
      it "should call simctl addmedia", requires_xcode: true do
        allow(Snapshot::TestCommandGenerator).to receive(:device_udid).and_return(device_udid)

        if FastlaneCore::Helper.xcode_at_least?("13")
          expect(Fastlane::Helper).to receive(:backticks)
            .with("open -a Simulator.app --args -CurrentDeviceUDID #{device_udid}", print: FastlaneCore::Globals.verbose?)
            .and_return("").exactly(1).times
        else
          expect(Fastlane::Helper).to receive(:backticks)
            .with("xcrun instruments -w #{device_udid}", print: FastlaneCore::Globals.verbose?)
            .and_return("").exactly(1).times
        end
        expect(Fastlane::Helper).to receive(:backticks)
          .with("xcrun simctl addmedia #{device_udid} #{paths.join(' ')}", print: FastlaneCore::Globals.verbose?)
          .and_return("").exactly(1).times

        # Verify that backticks isn't called for the fallback to addphoto/addvideo
        expect(Fastlane::Helper).to receive(:backticks).with(any_args).and_return(anything).exactly(0).times

        launcher = Snapshot::SimulatorLauncherBase.new
        launcher.add_media(['phone'], 'photo', paths)
      end

      it "should call simctl addmedia and fallback to addphoto", requires_xcode: true do
        allow(Snapshot::TestCommandGenerator).to receive(:device_udid).and_return(device_udid)

        if FastlaneCore::Helper.xcode_at_least?("13")
          expect(Fastlane::Helper).to receive(:backticks)
            .with("open -a Simulator.app --args -CurrentDeviceUDID #{device_udid}", print: FastlaneCore::Globals.verbose?)
            .and_return("").exactly(1).times
        else
          expect(Fastlane::Helper).to receive(:backticks)
            .with("xcrun instruments -w #{device_udid}", print: FastlaneCore::Globals.verbose?)
            .and_return("").exactly(1).times
        end

        expect(Fastlane::Helper).to receive(:backticks)
          .with("xcrun simctl addmedia #{device_udid} #{paths.join(' ')}", print: FastlaneCore::Globals.verbose?)
          .and_return("usage: simctl [--noxpc] [--set <path>] [--profiles <path>] <subcommand> ...\n").exactly(1).times

        expect(Fastlane::Helper).to receive(:backticks).with(any_args).and_return(anything).exactly(1).times

        launcher = Snapshot::SimulatorLauncherBase.new
        launcher.add_media(['phone'], 'photo', paths)
      end
    end

    describe '#override_status_bar' do
      before(:each) do
        allow(Snapshot::UI).to receive(:message)
        allow(Kernel).to receive(:sleep)
      end

      it "should use HH:MM format for time argument", requires_xcode: true do
        allow(Snapshot::TestCommandGenerator).to receive(:device_udid).and_return(device_udid)
        allow(ENV).to receive(:[]).with("SNAPSHOT_SIMULATOR_WAIT_FOR_BOOT_TIMEOUT").and_return(nil)

        expect(Fastlane::Helper).to receive(:backticks)
          .with("xcrun simctl bootstatus #{device_udid} -b", print: FastlaneCore::Globals.verbose?)
          .and_return("").exactly(1).times

        # Verify the time format is HH:MM (e.g., "09:41") not ISO8601
        expect(Fastlane::Helper).to receive(:backticks)
          .with(match(/xcrun simctl status_bar #{device_udid} override --time 09:41/), print: FastlaneCore::Globals.verbose?)
          .and_return("").exactly(1).times

        launcher = Snapshot::SimulatorLauncherBase.new
        launcher.override_status_bar('phone', nil)
      end

      it "should use custom arguments when provided", requires_xcode: true do
        allow(Snapshot::TestCommandGenerator).to receive(:device_udid).and_return(device_udid)
        allow(ENV).to receive(:[]).with("SNAPSHOT_SIMULATOR_WAIT_FOR_BOOT_TIMEOUT").and_return(nil)

        expect(Fastlane::Helper).to receive(:backticks)
          .with("xcrun simctl bootstatus #{device_udid} -b", print: FastlaneCore::Globals.verbose?)
          .and_return("").exactly(1).times

        custom_args = "--time 10:30 --dataNetwork lte"
        expect(Fastlane::Helper).to receive(:backticks)
          .with("xcrun simctl status_bar #{device_udid} override #{custom_args}", print: FastlaneCore::Globals.verbose?)
          .and_return("").exactly(1).times

        launcher = Snapshot::SimulatorLauncherBase.new
        launcher.override_status_bar('phone', custom_args)
      end
    end
  end
end
