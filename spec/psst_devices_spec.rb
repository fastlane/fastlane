require 'spec_helper'

describe Spaceship do
  describe "Devices" do
    before do
      @client = Spaceship::Client.new
    end

    it "successfully loads and parses all devices" do
      expect(@client.devices.count).to eq(13)
      device = @client.devices.first
      expect(device.id).to eq('RK3285QATH')
      expect(device.name).to eq('Felix Krause\'s iPhone 5')
      expect(device.udid).to eq('ba0ac7d70f7a14c6fa02ba0ac7d70f7a14c6fa02')
      expect(device.platform).to eq('ios')
      expect(device.status).to eq('c')
    end
  end
end