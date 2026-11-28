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

    context '#auth' do
      it 'with filepath' do
        key_id = "key_id"
        issuer_id = "issuer_id"
        filepath = "filepath"

        token = double('token')

        expect(Spaceship::ConnectAPI::Token).to receive(:create).with(key_id: key_id, issuer_id: issuer_id, filepath: filepath, key: nil, duration: nil, in_house: nil).and_return(token)
        expect(Spaceship::ConnectAPI::Client).to receive(:new).with(token: token)

        Spaceship::ConnectAPI::Client.auth(key_id: key_id, issuer_id: issuer_id, filepath: filepath)
      end

      it 'with key' do
        key_id = "key_id"
        issuer_id = "issuer_id"
        key = "key"

        token = double('token')

        expect(Spaceship::ConnectAPI::Token).to receive(:create).with(key_id: key_id, issuer_id: issuer_id, filepath: nil, key: key, duration: 100, in_house: true).and_return(token)
        expect(Spaceship::ConnectAPI::Client).to receive(:new).with(token: token)

        Spaceship::ConnectAPI::Client.auth(key_id: key_id, issuer_id: issuer_id, key: key, duration: 100, in_house: true)
      end
    end

    context '#login' do
      let(:username) { 'username' }
      let(:password) { 'password' }
      let(:team_id) { 'team_id' }
      let(:team_name) { 'team_name' }

      let(:tunes_client) { double('tunes_client') }
      let(:portal_client) { double('portal_client') }

      it 'no team_id or team_name' do
        stub_const('ENV', {})

        expect(Spaceship::PortalClient).to receive(:login).with(username, password).and_return(portal_client)
        expect(Spaceship::TunesClient).to receive(:login).with(username, password).and_return(tunes_client)
        expect(Spaceship::ConnectAPI::Client).to receive(:new).with(tunes_client: tunes_client, portal_client: portal_client)

        expect(portal_client).to receive(:select_team).with(team_id: nil, team_name: nil)
        expect(tunes_client).to receive(:select_team).with(team_id: nil, team_name: nil)

        Spaceship::ConnectAPI::Client.login(username, password)
      end

      it 'with portal_team_id' do
        stub_const('ENV', {})

        expect(Spaceship::PortalClient).to receive(:login).with(username, password).and_return(portal_client)
        expect(Spaceship::TunesClient).not_to(receive(:login).with(username, password))
        expect(Spaceship::ConnectAPI::Client).to receive(:new).with(tunes_client: nil, portal_client: portal_client)

        expect(portal_client).to receive(:select_team).with(team_id: team_id, team_name: nil)
        expect(tunes_client).not_to(receive(:select_team).with(team_id: team_id, team_name: nil))
        Spaceship::ConnectAPI::Client.login(username, password, use_portal: true, use_tunes: false, portal_team_id: team_id)
      end

      it 'with tunes_team_id' do
        stub_const('ENV', {})

        expect(Spaceship::PortalClient).not_to(receive(:login).with(username, password))
        expect(Spaceship::TunesClient).to receive(:login).with(username, password).and_return(tunes_client)
        expect(Spaceship::ConnectAPI::Client).to receive(:new).with(tunes_client: tunes_client, portal_client: nil)

        expect(portal_client).not_to(receive(:select_team).with(team_id: team_id, team_name: nil))
        expect(tunes_client).to receive(:select_team).with(team_id: team_id, team_name: nil)
        Spaceship::ConnectAPI::Client.login(username, password, use_portal: false, use_tunes: true, tunes_team_id: team_id)
      end

      it 'with team_name' do
        stub_const('ENV', {})

        expect(Spaceship::PortalClient).to receive(:login).with(username, password).and_return(portal_client)
        expect(Spaceship::TunesClient).to receive(:login).with(username, password).and_return(tunes_client)
        expect(Spaceship::ConnectAPI::Client).to receive(:new).with(tunes_client: tunes_client, portal_client: portal_client)

        expect(tunes_client).to receive(:select_team).with(team_id: nil, team_name: team_name)
        expect(portal_client).to receive(:select_team).with(team_id: nil, team_name: team_name)
        Spaceship::ConnectAPI::Client.login(username, password, team_name: team_name)
      end

      context 'with environment variables' do
        it 'with FASTLANE_TEAM_ID' do
          stub_const('ENV', { 'FASTLANE_TEAM_ID' => team_id })

          expect(Spaceship::PortalClient).to receive(:login).with(username, password).and_return(portal_client)
          expect(Spaceship::TunesClient).not_to(receive(:login).with(username, password))
          expect(Spaceship::ConnectAPI::Client).to receive(:new).with(tunes_client: nil, portal_client: portal_client)

          expect(portal_client).to receive(:select_team)
          expect(tunes_client).not_to(receive(:select_team))
          Spaceship::ConnectAPI::Client.login(username, password, use_portal: true, use_tunes: false)
        end

        it 'with FASTLANE_ITC_TEAM_ID' do
          stub_const('ENV', { 'FASTLANE_ITC_TEAM_ID' => team_id })

          expect(Spaceship::PortalClient).not_to(receive(:login).with(username, password))
          expect(Spaceship::TunesClient).to receive(:login).with(username, password).and_return(tunes_client)
          expect(Spaceship::ConnectAPI::Client).to receive(:new).with(tunes_client: tunes_client, portal_client: nil)

          expect(portal_client).not_to(receive(:select_team))
          expect(tunes_client).to receive(:select_team)
          Spaceship::ConnectAPI::Client.login(username, password, use_portal: false, use_tunes: true)
        end

        it 'with FASTLANE_TEAM_NAME' do
          stub_const('ENV', { 'FASTLANE_TEAM_NAME' => team_name })

          expect(Spaceship::PortalClient).to receive(:login).with(username, password).and_return(portal_client)
          expect(Spaceship::TunesClient).not_to(receive(:login).with(username, password))
          expect(Spaceship::ConnectAPI::Client).to receive(:new).with(tunes_client: nil, portal_client: portal_client)

          expect(portal_client).to receive(:select_team)
          expect(tunes_client).not_to(receive(:select_team))
          Spaceship::ConnectAPI::Client.login(username, password, use_portal: true, use_tunes: false)
        end

        it 'with FASTLANE_ITC_TEAM_NAME' do
          stub_const('ENV', { 'FASTLANE_ITC_TEAM_NAME' => team_name })

          expect(Spaceship::PortalClient).not_to(receive(:login).with(username, password))
          expect(Spaceship::TunesClient).to receive(:login).with(username, password).and_return(tunes_client)
          expect(Spaceship::ConnectAPI::Client).to receive(:new).with(tunes_client: tunes_client, portal_client: nil)

          expect(portal_client).not_to(receive(:select_team))
          expect(tunes_client).to receive(:select_team)
          Spaceship::ConnectAPI::Client.login(username, password, use_portal: false, use_tunes: true)
        end
      end
    end

    context "#in_house?" do
      context "with token" do
        let(:mock_token) { double('token') }
        let(:client) do
          Spaceship::ConnectAPI::Client.new(token: mock_token)
        end

        it "raise error without in_house set" do
          allow(mock_token).to receive(:in_house).and_return(nil)

          expect do
            client.in_house?
          end.to raise_error(/Cannot determine if team is App Store or Enterprise via the App Store Connect API/)
        end

        it "with in_house set" do
          allow(mock_token).to receive(:in_house).and_return(true)

          in_house = client.in_house?
          expect(in_house).to be(true)
        end
      end

      it "with portal client" do
        mock_portal_client =  double('portal client')
        allow(mock_portal_client).to receive(:team_id)
        allow(mock_portal_client).to receive(:csrf_tokens)

        client = Spaceship::ConnectAPI::Client.new(portal_client: mock_portal_client)

        expect(mock_portal_client).to receive(:in_house?).and_return(true)

        in_house = client.in_house?
        expect(in_house).to be(true)
      end

      it "raise error with no session" do
        client = Spaceship::ConnectAPI::Client.new
        expect do
          client.in_house?
        end.to raise_error("No App Store Connect API token or Portal Client set")
      end
    end
  end
end
