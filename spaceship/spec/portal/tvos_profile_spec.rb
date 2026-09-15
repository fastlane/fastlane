describe Spaceship::ProvisioningProfile do
  describe "Development tvOS Profiles" do
    # Skip tunes login and login with portal
    include_examples "common spaceship login", true
    before do
      Spaceship.login
      PortalStubbing.adp_enterprise_stubbing
    end
    let(:client) { Spaceship::ProvisioningProfile.client }

    describe "Create a new Development tvOS Profile" do
      it "uses the correct type for the create request" do
        cert = Spaceship::Certificate::Development.all.first
        result = Spaceship::ProvisioningProfile::Development.create!(name: 'Delete Me', bundle_id: 'net.sunapps.1', certificate: cert, devices: nil, mac: false, sub_platform: 'tvOS')
        expect(result.raw_data['provisioningProfileId']).to eq('W2MY88F6GE')
      end

      it "does not allow tvos as a subplatform" do
        cert = Spaceship::Certificate::Development.all.first
        expect do
          Spaceship::ProvisioningProfile::Development.create!(name: 'Delete Me', bundle_id: 'net.sunapps.1', certificate: cert, devices: nil, mac: false, sub_platform: 'tvos')
        end.to raise_error('Invalid sub_platform tvos, valid values are tvOS')
      end
    end
  end
end
