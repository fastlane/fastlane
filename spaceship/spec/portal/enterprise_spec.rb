describe Spaceship::ProvisioningProfile do
  describe "Enterprise Profiles" do
    before do
      Spaceship.login
      PortalStubbing.adp_enterprise_stubbing
    end
    let(:client) { Spaceship::ProvisioningProfile.client }

    describe "List the code signing certificate as In House profiles" do
      it "uses the correct class" do
        certs = Spaceship::Certificate::InHouse.all
        expect(certs.count).to eq(1)

        cert = certs.first
        expect(cert).to be_kind_of(Spaceship::Certificate::InHouse)
        expect(cert.name).to eq("SunApps GmbH")
      end
    end

    describe "Create a new In House Profile" do
      it "uses the correct type for the create request" do
        cert = Spaceship::Certificate::InHouse.all.first
        result = Spaceship::ProvisioningProfile::InHouse.create!(name: 'Delete Me', bundle_id: 'net.sunapps.1', certificate: cert)
        expect(result.raw_data['provisioningProfileId']).to eq('W2MY88F6GE')
      end
    end
  end
end
