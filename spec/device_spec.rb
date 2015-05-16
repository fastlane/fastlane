require 'spec_helper'

describe Spaceship::Device do
  before { Spaceship.login }
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
end
