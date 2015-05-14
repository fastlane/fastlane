require 'spec_helper'

describe Spaceship::ProvisioningProfiles do
  before { Spaceship.login }
  subject { Spaceship.provisioning_profiles }

  it "downloads an existing provisioning profile" do
    path = @client.fetch_provisioning_profile('net.sunapps.9', 'store').download

    # File is correct
    expect(path).to eq("/tmp/net.sunapps.9.store.mobileprovision")
    xml = Plist::parse_xml(File.read(path))
    expect(xml['AppIDName']).to eq("SunApp Setup")
    expect(xml['TeamName']).to eq("SunApps GmbH")
  end

  it "properly stores the provisioning profiles as structs" do
    expect(subject.count).to eq(33) # ignore the Xcode generated profiles

    profile = subject.last
    expect(profile.name).to eq('net.sunapps.9 Development')
    expect(profile.type).to eq('iOS Development')
    expect(profile.app_id).to eq('572SH8263D')
    expect(profile.status).to eq('Active')
    expect(profile.expiration.to_s).to eq('2016-03-05T11:46:57+00:00')
    expect(profile.uuid).to eq('34b221d4-31aa-4e55-9ea1-e5fac4f7ff8c')
    expect(profile.is_xcode_managed).to eq(false)
    expect(profile.distribution_method).to eq('limited')
  end

  it "updates the distribution method to adhoc if devices are enabled" do
    adhoc = subject[2]

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

  describe "Create a new profile" do
    before do
      ENV.delete "SIGH_PROVISIONING_PROFILE_NAME"
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
