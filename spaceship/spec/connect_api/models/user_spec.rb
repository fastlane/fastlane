describe Spaceship::ConnectAPI::User do
  let(:mock_tunes_client) { double('tunes_client') }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    allow(mock_tunes_client).to receive(:team_id).and_return("123")
    allow(mock_tunes_client).to receive(:select_team)
    allow(mock_tunes_client).to receive(:csrf_tokens)
    allow(Spaceship::TunesClient).to receive(:login).and_return(mock_tunes_client)
    Spaceship::ConnectAPI.login(username, password, use_portal: false, use_tunes: true)
  end

  describe '#Spaceship::ConnectAPI' do
    it '#get_users' do
      response = Spaceship::ConnectAPI.get_users
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::User)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.username).to eq("pizza@email.com")
      expect(model.first_name).to eq("Cheese")
      expect(model.last_name).to eq("Pizza")
      expect(model.email).to eq("pizza@email.com")
      expect(model.preferred_currency_territory).to eq("USD_USA")
      expect(model.agreed_to_terms).to eq(true)
      expect(model.roles).to eq(["ADMIN"])
      expect(model.all_apps_visible).to eq(true)
      expect(model.provisioning_allowed).to eq(true)
      expect(model.email_vetting_required).to eq(false)
      expect(model.notifications).to eq({})
    end
  end
end
