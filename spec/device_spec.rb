require 'spec_helper'

describe Spaceship::Device do
  before { Spaceship.login }
  let(:client) { Spaceship::Certificate.client }

  subject { Spaceship::Device.all }
  it "successfully loads and parses all devices" do
    expect(subject.count).to eq(4)
    device = subject.first
    expect(device.id).to eq('AAAAAAAAAA')
    expect(device.name).to eq('Felix\'s iPhone')
    expect(device.udid).to eq('a03b816861e89fac0a4da5884cb9d2f01bd5641e')
    expect(device.platform).to eq('ios')
    expect(device.status).to eq('c')
  end

  describe "#create" do
    it "should create and return a new device" do
      expect(client).to receive(:create_device!).with("Demo Device", "7f6c8dc83d77134b5a3a1c53f1202b395b04482b").and_return({})
      device = Spaceship::Device.create!("Demo Device", "7f6c8dc83d77134b5a3a1c53f1202b395b04482b")
    end

    it "should fail to create a nil device UDID" do
      expect {
        Spaceship::Device.create!("Demo Device", nil)
      }.to raise_error("You cannot create a device without a device_id (UDID) and device_name")
    end

    it "should fail to create a nil device name" do
      expect {
        Spaceship::Device.create!(nil, "7f6c8dc83d77134b5a3a1c53f1202b395b04482b")
      }.to raise_error("You cannot create a device without a device_id (UDID) and device_name")
    end
  end
end
