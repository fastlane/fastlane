require 'snapshot/reset_simulators'

describe Snapshot::ResetSimulators do
  let(:usable_devices) do
    [
      ["    iPhone 6s Plus (0311D4EC-14E7-443B-9F27-F32E72342799) (Shutdown)", "iPhone 6s Plus", "0311D4EC-14E7-443B-9F27-F32E72342799"],
      ["    iPad Pro (AD6A06DF-16EF-492D-8AF3-8128FCC03CBF) (Shutdown)", "iPad Pro", "AD6A06DF-16EF-492D-8AF3-8128FCC03CBF"],
      ["    Apple TV 1080p (D7D591A8-17D2-47B4-8D2A-AFAFA28874C9) (Shutdown)", "Apple TV 1080p", "D7D591A8-17D2-47B4-8D2A-AFAFA28874C9"],
      ["    Apple Watch - 38mm (2A58326E-50F3-4575-9049-E119A4E6852D) (Shutdown)", "Apple Watch - 38mm", "2A58326E-50F3-4575-9049-E119A4E6852D"],
      ["    Apple Watch - 42mm (C8250DD7-8C4E-4803-838A-731B42785262) (Shutdown)", "Apple Watch - 42mm", "C8250DD7-8C4E-4803-838A-731B42785262"]
    ]
  end

  let(:unusable_devices) do
    [
      ["    Apple Watch - 38mm (22C04589-2AD4-42BB-9869-FB2331708E62) (Creating) (unavailable, runtime profile not found)", "Apple Watch - 38mm", "22C04589-2AD4-42BB-9869-FB2331708E62"],
      ["    Apple Watch - 42mm (B98D4701-C719-41CD-BCCD-1288464D9B26) (Creating) (unavailable, runtime profile not found)", "Apple Watch - 42mm", "B98D4701-C719-41CD-BCCD-1288464D9B26"],
      ["    Apple Watch - 38mm (AF341B69-678E-48B0-9D12-A7502662D1BE) (Creating) (unavailable, runtime profile not found)", "Apple Watch - 38mm", "AF341B69-678E-48B0-9D12-A7502662D1BE"],
      ["    Apple Watch - 42mm (D2C4CBD0-DF62-45E3-8E25-72201827482E) (Creating) (unavailable, runtime profile not found)", "Apple Watch - 42mm", "D2C4CBD0-DF62-45E3-8E25-72201827482E"]
    ]
  end

  let(:runtimes) do
    [
      ["iOS 10.3", "com.apple.CoreSimulator.SimRuntime.iOS-10-3"],
      ["tvOS 10.2", "com.apple.CoreSimulator.SimRuntime.tvOS-10-2"],
      ["watchOS 3.2", "com.apple.CoreSimulator.SimRuntime.watchOS-3-2"]
    ]
  end

  let(:all_devices) do
    usable_devices + unusable_devices
  end

  let(:fixture_data) { File.read('snapshot/spec/fixtures/xcrun-simctl-list-devices.txt') }

  let(:fixture_runtimes_xcode8) { File.read('snapshot/spec/fixtures/xcrun-simctl-list-runtimes-Xcode8.txt') }

  let(:fixture_runtimes_xcode9) { File.read('snapshot/spec/fixtures/xcrun-simctl-list-runtimes-Xcode9.txt') }

  describe '#devices' do
    it 'should read simctl output into arrays of device info' do
      expect(FastlaneCore::Helper).to receive(:backticks).with(/xcrun simctl list devices/, print: FastlaneCore::Globals.verbose?).and_return(fixture_data)

      expect(Snapshot::ResetSimulators.devices).to eq(all_devices)
    end
  end

  describe '#clear_everything' do
    describe 'runtimes' do
      it "should find runtimes that are available for Xcode 8" do
        expect(FastlaneCore::Helper).to receive(:backticks).with(/xcrun simctl list runtimes/, print: FastlaneCore::Globals.verbose?).and_return(fixture_runtimes_xcode8)
        expect(Snapshot::ResetSimulators.runtimes).to eq(runtimes)
      end

      it "should find runtimes that are available for Xcode 9" do
        expect(FastlaneCore::Helper).to receive(:backticks).with(/xcrun simctl list runtimes/, print: FastlaneCore::Globals.verbose?).and_return(fixture_runtimes_xcode9)
        expect(Snapshot::ResetSimulators.runtimes).to eq(runtimes)
      end
    end
  end

  describe '#device_line_usable?' do
    describe 'usable devices' do
      it "should find normal devices to be be usable" do
        usable_devices.each do |usable|
          expect(Snapshot::ResetSimulators.device_line_usable?(usable[0])).to be(true)
        end
      end
    end

    describe 'unusable devices' do
      it "should find devices in bad states to be be unusable" do
        unusable_devices.each do |unusable|
          expect(Snapshot::ResetSimulators.device_line_usable?(unusable[0])).to be(false)
        end
      end
    end
  end

  describe '#make_phone_watch_pair' do
    describe 'with no phones present' do
      it 'does not call out to simctl' do
        mocked_devices = [
          ["    iPad Pro (AD6A06DF-16EF-492D-8AF3-8128FCC03CBF) (Shutdown)", "iPad Pro", "AD6A06DF-16EF-492D-8AF3-8128FCC03CBF"],
          ["    Apple TV 1080p (D7D591A8-17D2-47B4-8D2A-AFAFA28874C9) (Shutdown)", "Apple TV 1080p", "D7D591A8-17D2-47B4-8D2A-AFAFA28874C9"],
          ["    Apple Watch - 38mm (2A58326E-50F3-4575-9049-E119A4E6852D) (Shutdown)", "Apple Watch - 38mm", "2A58326E-50F3-4575-9049-E119A4E6852D"],
          ["    Apple Watch - 42mm (C8250DD7-8C4E-4803-838A-731B42785262) (Shutdown)", "Apple Watch - 42mm", "C8250DD7-8C4E-4803-838A-731B42785262"]
        ]
        expect(Snapshot::ResetSimulators).to receive(:devices).and_return(mocked_devices)
        expect(FastlaneCore::Helper).not_to(receive(:backticks))

        Snapshot::ResetSimulators.make_phone_watch_pair
      end
    end

    describe 'with no watches present' do
      it 'does not call out to simctl' do
        mocked_devices = [
          ["    iPhone 6s Plus (0311D4EC-14E7-443B-9F27-F32E72342799) (Shutdown)", "iPhone 6s Plus", "0311D4EC-14E7-443B-9F27-F32E72342799"],
          ["    iPad Pro (AD6A06DF-16EF-492D-8AF3-8128FCC03CBF) (Shutdown)", "iPad Pro", "AD6A06DF-16EF-492D-8AF3-8128FCC03CBF"],
          ["    Apple TV 1080p (D7D591A8-17D2-47B4-8D2A-AFAFA28874C9) (Shutdown)", "Apple TV 1080p", "D7D591A8-17D2-47B4-8D2A-AFAFA28874C9"]
        ]
        expect(Snapshot::ResetSimulators).to receive(:devices).and_return(mocked_devices)
        expect(FastlaneCore::Helper).not_to(receive(:backticks))

        Snapshot::ResetSimulators.make_phone_watch_pair
      end
    end

    describe 'with an available phone-watch pair' do
      it 'calls out to simctl pair' do
        expected_command = "xcrun simctl pair C8250DD7-8C4E-4803-838A-731B42785262 0311D4EC-14E7-443B-9F27-F32E72342799"

        # By checking against all_devices, we expect those which are in an unusable state
        # NOT to be selected!
        expect(Snapshot::ResetSimulators).to receive(:devices).and_return(all_devices)
        expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: FastlaneCore::Globals.verbose?)

        Snapshot::ResetSimulators.make_phone_watch_pair
      end
    end
  end
end
