require 'spec_helper'

describe Spaceship do
  before { Spaceship.login }

  it 'should initialize with a client' do
    expect(Spaceship.client).to be_instance_of(Spaceship::Client)
  end

  it 'should return apps' do
    expect(Spaceship.apps).to be_instance_of(Spaceship::Apps)
  end

  it 'should return certificates' do
    expect(Spaceship.certificates).to be_instance_of(Spaceship::Certificates)
  end

  it 'should return devices' do
    expect(Spaceship.devices).to be_instance_of(Spaceship::Devices)
  end

  it 'should return provisioning profiles' do
    expect(Spaceship.provisioning_profiles).to be_instance_of(Spaceship::ProvisioningProfiles)
  end
end
