describe Spaceship::ConnectAPI::Client do
  context 'create instance' do
    it '#initialize' do
      cookie = double('cookie')
      current_team_id = double('current_team_id')
      token = double('token')
      other_tunes_client = double('tunes_client')
      other_portal_client = double('portal_client')

      portal_args = { cookie: cookie, current_team_id: current_team_id, token: token, another_client: other_portal_client }
      tunes_args = { cookie: cookie, current_team_id: current_team_id, token: token, another_client: other_tunes_client }

      provisioning_client = double('provisioning_client')
      test_flight_client = double('test_flight_client')
      tunes_client = double('tunes_client')
      users_client = double('users_client')

      # Creates the API clients for the modules
      expect(Spaceship::ConnectAPI::Provisioning::Client).to receive(:new).with(portal_args)
                                                                          .and_return(provisioning_client)
      expect(Spaceship::ConnectAPI::TestFlight::Client).to receive(:new).with(tunes_args)
                                                                        .and_return(test_flight_client)
      expect(Spaceship::ConnectAPI::Tunes::Client).to receive(:new).with(tunes_args)
                                                                   .and_return(tunes_client)
      expect(Spaceship::ConnectAPI::Users::Client).to receive(:new).with(tunes_args)
                                                                   .and_return(users_client)

      # Create client
      client = Spaceship::ConnectAPI::Client.new(
        cookie: cookie,
        current_team_id: current_team_id,
        token: token,
        tunes_client: other_tunes_client,
        portal_client: other_portal_client
      )

      expect(client.tunes_client).to eq(other_tunes_client)
      expect(client.portal_client).to eq(other_portal_client)

      expect(client.provisioning_request_client).to eq(provisioning_client)
      expect(client.test_flight_request_client).to eq(test_flight_client)
      expect(client.tunes_request_client).to eq(tunes_client)
      expect(client.users_request_client).to eq(users_client)
    end

    it '#auth' do
      key_id = "key_id"
      issuer_id = "issuer_id"
      filepath = "filepath"

      token = double('token')

      expect(Spaceship::ConnectAPI::Token).to receive(:create).with(key_id: key_id, issuer_id: issuer_id, filepath: filepath).and_return(token)
      expect(Spaceship::ConnectAPI::Client).to receive(:new).with(token: token)

      Spaceship::ConnectAPI::Client.auth(key_id: key_id, issuer_id: issuer_id, filepath: filepath)
    end

    context '#login' do
      let(:username) { 'username' }
      let(:password) { 'password' }
      let(:team_id) { 'team_id' }
      let(:team_name) { 'team_name' }

      let(:tunes_client) { double('tunes_client') }
      let(:portal_client) { double('portal_client') }

      before(:each) do
        expect(Spaceship::TunesClient).to receive(:login).with(username, password).and_return(tunes_client)
        expect(Spaceship::PortalClient).to receive(:login).with(username, password).and_return(portal_client)

        expect(Spaceship::ConnectAPI::Client).to receive(:new).with(tunes_client: tunes_client, portal_client: portal_client)
      end

      it 'no team_id or team_name' do
        Spaceship::ConnectAPI::Client.login(username, password)
      end

      it 'with team_id' do
        expect(tunes_client).to receive(:select_team).with(team_id: team_id, team_name: nil)
        expect(portal_client).to receive(:select_team).with(team_id: team_id, team_name: nil)
        Spaceship::ConnectAPI::Client.login(username, password, team_id: team_id)
      end

      it 'with team_name' do
        expect(tunes_client).to receive(:select_team).with(team_id: nil, team_name: team_name)
        expect(portal_client).to receive(:select_team).with(team_id: nil, team_name: team_name)
        Spaceship::ConnectAPI::Client.login(username, password, team_name: team_name)
      end
    end
  end
end
