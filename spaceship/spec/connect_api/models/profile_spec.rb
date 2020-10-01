describe Spaceship::ConnectAPI::Profile do
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
    it '#get_profiles' do
      response = Spaceship::ConnectAPI.get_profiles
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::Profile)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.name).to eq("match AppStore com.joshholtz.FastlaneApp 1560136558")
      expect(model.platform).to eq("IOS")
      expect(model.profile_content).to eq("content")
      expect(model.uuid).to eq("7ecd2cf1-3eb1-48b5-94e3-eb60eeaf5ad6")
      expect(model.created_date).to eq("2019-06-10T03:15:58.000+0000")
      expect(model.profile_state).to eq("ACTIVE")
      expect(model.profile_type).to eq("IOS_APP_STORE")
      expect(model.expiration_date).to eq("2020-05-01T15:18:38.000+0000")
    end
  end
end
