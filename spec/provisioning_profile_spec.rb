require 'spec_helper'

describe Spaceship::ProvisioningProfile do
  before { Spaceship.login }
  let(:client) { Spaceship::ProvisioningProfile.client }

  describe '#all' do
    let(:provisioning_profiles) { Spaceship::ProvisioningProfile.all }

    it "properly retrieves and filters the provisioning profiles" do
      expect(provisioning_profiles.count).to eq(33) # ignore the Xcode generated profiles

      profile = provisioning_profiles.last
      expect(profile.name).to eq('net.sunapps.9 Development')
      expect(profile.type).to eq('iOS Development')
      expect(profile.app.app_id).to eq('572SH8263D')
      expect(profile.status).to eq('Active')
      expect(profile.expires.to_s).to eq('2016-03-05T11:46:57+00:00')
      expect(profile.uuid).to eq('34b221d4-31aa-4e55-9ea1-e5fac4f7ff8c')
      expect(profile.managed_by_xcode?).to eq(false)
      expect(profile.distribution_method).to eq('limited')
      expect(profile.class.type).to eq('limited')
      expect(profile.class.pretty_type).to eq('Development')
      expect(profile.type).to eq('iOS Development')
    end

    it 'should filter by the correct types' do
      expect(Spaceship::ProvisioningProfile::Development.all.count).to eq(3)
      expect(Spaceship::ProvisioningProfile::AdHoc.all.count).to eq(13)
      expect(Spaceship::ProvisioningProfile::AppStore.all.count).to eq(17)
    end

    it 'should have an app' do
      profile = provisioning_profiles.first
      expect(profile.app).to be_instance_of(Spaceship::App)
    end
  end

  it "updates the distribution method to adhoc if devices are enabled" do
    adhoc = Spaceship::ProvisioningProfile::AdHoc.all.first

    expect(adhoc.distribution_method).to eq('adhoc')
    expect(adhoc.devices.count).to eq(13)

    device = adhoc.devices.first
    expect(device.id).to eq('RK3285QATH')
    expect(device.name).to eq('Felix Krause\'s iPhone 5')
    expect(device.udid).to eq('aaabbbccccddddaaabbb')
    expect(device.platform).to eq('ios')
    expect(device.status).to eq('c')
  end

  describe '#download' do
    it "downloads an existing provisioning profile" do
      file = Spaceship::ProvisioningProfile.all.first.download
      xml = Plist::parse_xml(file)
      expect(xml['AppIDName']).to eq("SunApp Setup")
      expect(xml['TeamName']).to eq("SunApps GmbH")
    end
  end

  describe '#create!' do
    let(:certificate) { Spaceship::Certificate.all.first }

    it 'creates a new development provisioning profile' do
      expect(client).to receive(:create_provisioning_profile!).with('Delete Me', 'limited', '2UMR2S6PAA', ["XC5PH8DAAA"], ["AAAAAAAAAA", "BBBBBBBBBB", "CCCCCCCCCC", "DDDDDDDDDD"]).and_return({})
      Spaceship::ProvisioningProfile::Development.create!(name: 'Delete Me', bundle_id: 'net.sunapps.1', certificate: certificate)
    end

    it 'creates a new appstore provisioning profile' do
      expect(client).to receive(:create_provisioning_profile!).with('Delete Me', 'store', '2UMR2S6PAA', ["XC5PH8DAAA"], []).and_return({})
      Spaceship::ProvisioningProfile::AppStore.create!(name: 'Delete Me', bundle_id: 'net.sunapps.1', certificate: certificate)
    end

    it 'creates a provisioning profile with only the required parameters and auto fills all available devices' do
      expect(client).to receive(:create_provisioning_profile!).with('net.sunapps.1 AppStore', 
                                                                    'store', 
                                                                    '2UMR2S6PAA', 
                                                                    ["XC5PH8DAAA"], 
                                                                    []).
                        and_return({})
      Spaceship::ProvisioningProfile::AppStore.create!(bundle_id: 'net.sunapps.1', certificate: certificate)
    end
  end

  describe "#repair" do
    let (:profile) { Spaceship::ProvisioningProfile.all.first }

    it "repairs an existing profile with added devices" do
      profile.devices = Spaceship.devices
      expect(client).to receive(:repair_provisioning_profile!).with('2MAY7NPHRU', 'net.sunapps.7 AppStore', 'store', '572XTN75U2', ["XC5PH8D47H"], ["AAAAAAAAAA", "BBBBBBBBBB", "CCCCCCCCCC", "DDDDDDDDDD"]).and_return({})
      profile.repair!
    end

    it "repairs an existing profile with no devices" do
      expect(client).to receive(:repair_provisioning_profile!).with('2MAY7NPHRU', 'net.sunapps.7 AppStore', 'store', '572XTN75U2', ["XC5PH8D47H"], []).and_return({})
      profile.repair!
    end
  end

  describe "#update!" do
    let (:profile) { Spaceship::ProvisioningProfile.all.first }

    it "updates an existing profile" do
      expect(client).to receive(:repair_provisioning_profile!).with('2MAY7NPHRU', 'net.sunapps.7 AppStore', 'store', '572XTN75U2', ["XC5PH8D47H"], []).and_return({})
      profile.update!
    end
  end
end
