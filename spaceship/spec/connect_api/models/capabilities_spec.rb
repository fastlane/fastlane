describe Spaceship::ConnectAPI::Capabilities do
  let(:mock_portal_client) { double('portal_client') }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    allow(mock_portal_client).to receive(:team_id).and_return("123")
    allow(mock_portal_client).to receive(:select_team)
    allow(mock_portal_client).to receive(:csrf_tokens)
    allow(Spaceship::PortalClient).to receive(:login).and_return(mock_portal_client)
    Spaceship::ConnectAPI.login(username, password, use_portal: true, use_tunes: false)
  end

  describe '#client' do
    it '#get_available_bundle_id_capabilities' do
      response = Spaceship::ConnectAPI.get_available_bundle_id_capabilities(bundle_id_id: '123456789')
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::Capabilities)
      end

      model = response.first
      expect(model.id).to eq("ACCESS_WIFI_INFORMATION")
      expect(model.name).to eq("Access WiFi Information")
    end
  end
end
