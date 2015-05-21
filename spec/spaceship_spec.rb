require 'spec_helper'

describe Spaceship do
  before { Spaceship.login }

  it 'should initialize with a client' do
    expect(Spaceship.client).to be_instance_of(Spaceship::Client)
  end

  it 'should return apps' do
    expect(Spaceship.apps.sample).to be_kind_of(Spaceship::App)
  end

  it 'should return certificates' do
    expect(Spaceship.certificates.sample).to be_kind_of(Spaceship::Certificate)
  end

  it 'should return devices' do
    expect(Spaceship.devices.sample).to be_kind_of(Spaceship::Device)
  end

  it 'should return provisioning profiles' do
    expect(Spaceship.provisioning_profiles.sample).to be_kind_of(Spaceship::ProvisioningProfile)
  end
end
