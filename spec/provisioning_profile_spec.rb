require 'spec_helper'

describe Spaceship::ProvisioningProfile do
  before { Spaceship.login }
  let(:client) { Spaceship::ProvisioningProfile.client }

  it "downloads an existing provisioning profile" do
    file = Spaceship::ProvisioningProfile.all.first.download
    xml = Plist::parse_xml(file)
    expect(xml['AppIDName']).to eq("SunApp Setup")
    expect(xml['TeamName']).to eq("SunApps GmbH")
  end

  it "properly stores the provisioning profiles as structs" do
    expect(Spaceship::ProvisioningProfile.all.count).to eq(33) # ignore the Xcode generated profiles

    profile = Spaceship::ProvisioningProfile.all.last
    expect(profile.name).to eq('delete.me.please AppStore')
    expect(profile.type).to eq('iOS Distribution')
    expect(profile.app.app_id).to eq('2UMR2S6P4L')
    expect(profile.status).to eq('Invalid')
    expect(profile.expires.to_s).to eq('2016-02-10')
    expect(profile.uuid).to eq('58ce5b78-15f8-4ceb-83f1-a29f6c4d066f')
    expect(profile.managed_by_xcode?).to eq(false)
    expect(profile.distribution_method).to eq('adhoc')
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

  it "raises an exception when passing an invalid distribution type" do
    expect {
      @client.fetch_provisioning_profile('net.sunapps.999', 'invalid_parameter')
    }.to raise_exception("Invalid distribution_method 'invalid_parameter'".red)
  end

  describe '#create' do
    let(:certificate) { Spaceship::Certificate.all.first }
    it 'creates a new profivisioning profile' do
      expect(client).to receive(:create_provisioning_profile!).with('Delete Me', 'limited', '2UMR2S6PAA', ["XC5PH8DAAA"], []).and_return({})
      Spaceship::ProvisioningProfile::Development.create!(name: 'Delete Me', bundle_id: 'net.sunapps.1', certificate: certificate)
    end

    # TODO: Fix test after configuration was finished
    # it "creates a new provisioning profile if it doesn't exist" do
    #   ENV["SIGH_PROVISIONING_PROFILE_NAME"] = "Not Yet Taken" # custom name
    #   path = @client.fetch_provisioning_profile('net.sunapps.106', 'limited').download
    # end

    it "Throws a warning if name is already taken" do
      expect {
        # This uses the standard name which is already taken
        @client.fetch_provisioning_profile('net.sunapps.106', 'limited').download
      }.to raise_exception('Multiple profiles found with the name "Test Name 3".  Please remove the duplicate profiles and try again.\nThere are no current certificates on this team matching the provided certificate IDs.'.red)
    end
  end
end
