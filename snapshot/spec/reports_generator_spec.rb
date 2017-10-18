require 'snapshot/reports_generator'

describe Snapshot::ReportsGenerator do
  describe '#available_devices' do
    # the Collector generates file names that remove all spaces from the device names, so
    # any keys here can't contain spaces
    it "xcode 8 devices don't have keys that contain spaces" do
      allow(FastlaneCore::Helper).to receive(:xcode_at_least?).with("9.0").and_return(false)

      device_name_keys = Snapshot::ReportsGenerator.new.available_devices.keys
      expect(device_name_keys.none? { |k| k.include?(' ') }).to be(true)
    end

    it "xcode 9 devices have keys that contain spaces" do
      allow(FastlaneCore::Helper).to receive(:xcode_at_least?).with("9.0").and_return(false)

      device_name_keys = Snapshot::ReportsGenerator.new.available_devices.keys
      expect(device_name_keys.none? { |k| k.include?(' ') }).to be(true)
    end
  end
end
