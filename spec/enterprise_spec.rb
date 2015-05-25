require 'spec_helper'

def enterprise_subbing
  stub_request(:post, "https://developer.apple.com/services-account/QH65B2/account/ios/certificate/listCertRequests.action").
         with(:body => {"pageNumber"=>"1", "pageSize"=>"500", "sort"=>"certRequestStatusCode=asc", "teamId"=>"XXXXXXXXXX", "types"=>"9RQEK7MSXA"},
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'Cookie'=>'myacinfo=abcdef;', 'User-Agent'=>'spaceship'}).
         to_return(:status => 200, :body => read_fixture_file(File.join("enterprise", "listCertRequests.action.json")), :headers => {'Content-Type' => 'application/json'})
end

describe Spaceship::ProvisioningProfile do
  describe "Enterprise Profiles" do
    before do
      Spaceship.login

      enterprise_subbing
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
        expect(client).to receive(:create_provisioning_profile!).with('Delete Me', 'inhouse', '2UMR2S6PAA', [cert.id], []).and_return({})
        Spaceship::ProvisioningProfile::InHouse.create!(name: 'Delete Me', bundle_id: 'net.sunapps.1', certificate: cert)
      end
    end
  end
end
