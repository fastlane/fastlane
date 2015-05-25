require 'spec_helper'

describe Spaceship do
  before { Spaceship.login }

  it 'should initialize with a client' do
    expect(Spaceship.client).to be_instance_of(Spaceship::Client)
  end

  describe Spaceship::Control do
    it 'has a client' do
      expect(subject.client).to be_instance_of(Spaceship::Client)
    end

    it 'returns a scoped model class' do
      expect(subject.app).to eq(Spaceship::App)
      expect(subject.certificate).to eq(Spaceship::Certificate)
      expect(subject.device).to eq(Spaceship::Device)
      expect(subject.provisioning_profile).to eq(Spaceship::ProvisioningProfile)
    end
    it 'passes the client to the models' do
      expect(subject.device.client).to eq(subject.client)
    end
  end
end
