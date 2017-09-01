describe Spaceship do
  before { Spaceship.login }

  it "#select_team" do
    expect(Spaceship.select_team).to eq('XXXXXXXXXX')
  end

  it 'should initialize with a client' do
    expect(Spaceship.client).to be_instance_of(Spaceship::PortalClient)
  end

  it "Device" do
    expect(Spaceship.device.all.count).to eq(4)
  end

  it "Certificate" do
    expect(Spaceship.certificate.all.count).to eq(3)
  end

  it "ProvisioningProfile" do
    expect(Spaceship.provisioning_profile.all.count).to eq(7)
  end

  it "App" do
    expect(Spaceship.app.all.count).to eq(5)
  end

  it "App Group" do
    expect(Spaceship.app_group.all.count).to eq(2)
  end

  describe Spaceship::Launcher do
    it 'has a client' do
      expect(subject.client).to be_instance_of(Spaceship::PortalClient)
    end

    it 'returns a scoped model class' do
      expect(subject.app).to eq(Spaceship::App)
      expect(subject.app_group).to eq(Spaceship::AppGroup)
      expect(subject.certificate).to eq(Spaceship::Certificate)
      expect(subject.device).to eq(Spaceship::Device)
      expect(subject.provisioning_profile).to eq(Spaceship::ProvisioningProfile)
    end

    it 'passes the client to the models' do
      expect(subject.device.client).to eq(subject.client)
    end
  end
end
