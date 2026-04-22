describe Snapshot do
  describe Snapshot::SimulatorLauncherBase do
    let(:device_udid) { "123456789" }
    let(:paths) { ['./logo.png'] }

    describe '#add_media' do
      it "should call simctl addmedia", requires_xcode: true do
        allow(Snapshot::TestCommandGenerator).to receive(:device_udid).and_return(device_udid)

        if FastlaneCore::Helper.xcode_at_least?("13")
          expect(Fastlane::Helper).to receive(:backticks)
            .with("open -a Simulator.app --args -CurrentDeviceUDID #{device_udid} &> /dev/null")
            .and_return("").exactly(1).times
        else
          expect(Fastlane::Helper).to receive(:backticks)
            .with("xcrun instruments -w #{device_udid} &> /dev/null")
            .and_return("").exactly(1).times
        end
        expect(Fastlane::Helper).to receive(:backticks)
          .with("xcrun simctl addmedia #{device_udid} #{paths.join(' ')} &> /dev/null")
          .and_return("").exactly(1).times

        # Verify that backticks isn't called for the fallback to addphoto/addvideo
        expect(Fastlane::Helper).to receive(:backticks).with(anything).and_return(anything).exactly(0).times

        launcher = Snapshot::SimulatorLauncherBase.new
        launcher.add_media(['phone'], 'photo', paths)
      end

      it "should call simctl addmedia and fallback to addphoto", requires_xcode: true do
        allow(Snapshot::TestCommandGenerator).to receive(:device_udid).and_return(device_udid)

        if FastlaneCore::Helper.xcode_at_least?("13")
          expect(Fastlane::Helper).to receive(:backticks)
            .with("open -a Simulator.app --args -CurrentDeviceUDID #{device_udid} &> /dev/null")
            .and_return("").exactly(1).times
        else
          expect(Fastlane::Helper).to receive(:backticks)
            .with("xcrun instruments -w #{device_udid} &> /dev/null")
            .and_return("").exactly(1).times
        end

        expect(Fastlane::Helper).to receive(:backticks)
          .with("xcrun simctl addmedia #{device_udid} #{paths.join(' ')} &> /dev/null")
          .and_return("usage: simctl [--noxpc] [--set <path>] [--profiles <path>] <subcommand> ...\n").exactly(1).times

        expect(Fastlane::Helper).to receive(:backticks).with(anything).and_return(anything).exactly(1).times

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
          .with("xcrun simctl bootstatus #{device_udid} -b &> /dev/null")
          .and_return("").exactly(1).times

        # Verify the time format is HH:MM (e.g., "09:41") not ISO8601
        expect(Fastlane::Helper).to receive(:backticks)
          .with(match(/xcrun simctl status_bar #{device_udid} override --time 09:41/))
          .and_return("").exactly(1).times

        launcher = Snapshot::SimulatorLauncherBase.new
        launcher.override_status_bar('phone', nil)
      end

      it "should use custom arguments when provided", requires_xcode: true do
        allow(Snapshot::TestCommandGenerator).to receive(:device_udid).and_return(device_udid)
        allow(ENV).to receive(:[]).with("SNAPSHOT_SIMULATOR_WAIT_FOR_BOOT_TIMEOUT").and_return(nil)

        expect(Fastlane::Helper).to receive(:backticks)
          .with("xcrun simctl bootstatus #{device_udid} -b &> /dev/null")
          .and_return("").exactly(1).times

        custom_args = "--time 10:30 --dataNetwork lte"
        expect(Fastlane::Helper).to receive(:backticks)
          .with("xcrun simctl status_bar #{device_udid} override #{custom_args} &> /dev/null")
          .and_return("").exactly(1).times

        launcher = Snapshot::SimulatorLauncherBase.new
        launcher.override_status_bar('phone', custom_args)
      end
    end
  end
end
