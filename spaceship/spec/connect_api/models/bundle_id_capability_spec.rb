describe Spaceship::ConnectAPI::BundleIdCapability do
  let(:mock_portal_client) { double('portal_client') }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    allow(mock_portal_client).to receive(:team_id).and_return("123")
    allow(mock_portal_client).to receive(:select_team)
    allow(Spaceship::PortalClient).to receive(:login).and_return(mock_portal_client)
    Spaceship::ConnectAPI.login(username, password, use_portal: true, use_tunes: false)
  end

  describe '#client' do
    it 'through #get_bundle_id' do
      response = Spaceship::ConnectAPI.get_bundle_id(bundle_id_id: '123456789')
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)
      expect(response.first).to be_an_instance_of(Spaceship::ConnectAPI::BundleId)

      bundle_id_capabilities = response.first.bundle_id_capabilities

      expect(bundle_id_capabilities.count).to eq(2)
      bundle_id_capabilities.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BundleIdCapability)
      end
    end
  end
end
