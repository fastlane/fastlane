describe Spaceship::ConnectAPI do
  before(:all) do
    Spaceship::ConnectAPI.client = nil
    Spaceship::Tunes.client = nil
    Spaceship::Portal.client = nil
  end

  context '#client' do
    let(:mock_client) { double('mock_client') }

    let(:mock_tunes_client) { double('tunes_client') }
    let(:mock_portal_client) { double('portal_client') }

    before(:each) do
      allow(mock_tunes_client).to receive(:team_id).and_return("team_id")
      allow(mock_portal_client).to receive(:team_id).and_return("team_id")
      allow(mock_tunes_client).to receive(:csrf_tokens)
      allow(mock_portal_client).to receive(:csrf_tokens)
    end

    context 'with implicit client' do
      it 'returns client with using existing Tunes session' do
        allow(Spaceship::Tunes).to receive(:client).and_return(mock_tunes_client)

        client = Spaceship::ConnectAPI.client

        expect(client).not_to(be_nil)
        expect(client.tunes_client).to eq(mock_tunes_client)
        expect(client.portal_client).to eq(nil)
      end

      it 'returns client with using existing Portal session' do
        allow(Spaceship::Portal).to receive(:client).and_return(mock_portal_client)

        client = Spaceship::ConnectAPI.client

        expect(client).not_to(be_nil)
        expect(client.tunes_client).to eq(nil)
        expect(client.portal_client).to eq(mock_portal_client)
      end

      it 'returns client with using existing Tunes and Portal session' do
        allow(Spaceship::Tunes).to receive(:client).and_return(mock_tunes_client)
        allow(Spaceship::Portal).to receive(:client).and_return(mock_portal_client)

        client = Spaceship::ConnectAPI.client

        expect(client).not_to(be_nil)
        expect(client.tunes_client).to eq(mock_tunes_client)
        expect(client.portal_client).to eq(mock_portal_client)
      end

      it 'returns nil when no existing sessions' do
        client = Spaceship::ConnectAPI.client
        expect(client).to(be_nil)
      end
    end

    context 'with explicit client' do
      it '#auth' do
        key_id = 'key_id'
        issuer_id = 'issuer_id'
        filepath = 'filepath'

        expect(Spaceship::ConnectAPI::Client).to receive(:auth).with(key_id: key_id, issuer_id: issuer_id, filepath: filepath, key: nil, duration: nil, in_house: nil).and_return(mock_client)

        client = Spaceship::ConnectAPI.auth(key_id: key_id, issuer_id: issuer_id, filepath: filepath)
        expect(client).to eq(Spaceship::ConnectAPI.client)
      end

      context '#login' do
        it 'with portal_team_id' do
          user = 'user'
          password = 'password'
          team_id = 'team_id'
          team_name = 'team_name'

          expect(Spaceship::ConnectAPI::Client).to receive(:login).with(user, password, use_portal: true, use_tunes: false, portal_team_id: team_id, tunes_team_id: nil, team_name: team_name, skip_select_team: false).and_return(mock_client)

          client = Spaceship::ConnectAPI.login(user, password, use_portal: true, use_tunes: false, portal_team_id: team_id, team_name: team_name)
          expect(client).to eq(Spaceship::ConnectAPI.client)
        end

        it 'with tunes_team_id' do
          user = 'user'
          password = 'password'
          team_id = 'team_id'
          team_name = 'team_name'

          expect(Spaceship::ConnectAPI::Client).to receive(:login).with(user, password, use_portal: false, use_tunes: true, portal_team_id: nil, tunes_team_id: team_id, team_name: team_name, skip_select_team: false).and_return(mock_client)

          client = Spaceship::ConnectAPI.login(user, password, use_portal: false, use_tunes: true, tunes_team_id: team_id, team_name: team_name)
          expect(client).to eq(Spaceship::ConnectAPI.client)
        end

        it 'with both portal_team_id and tunes_team_id' do
          user = 'user'
          password = 'password'
          team_id = 'team_id'
          team_name = 'team_name'

          expect(Spaceship::ConnectAPI::Client).to receive(:login).with(user, password, use_portal: true, use_tunes: true, portal_team_id: team_id, tunes_team_id: team_id, team_name: team_name, skip_select_team: false).and_return(mock_client)

          client = Spaceship::ConnectAPI.login(user, password, use_portal: true, use_tunes: true, portal_team_id: team_id, tunes_team_id: team_id, team_name: team_name)
          expect(client).to eq(Spaceship::ConnectAPI.client)
        end
      end
    end
  end

  context '#select_team' do
    let(:mock_client) { double('mock_client') }

    let(:team_id) { "team_id" }
    let(:team_name) { "team name" }

    context 'with client' do
      it 'with portal_team_id' do
        allow(Spaceship::ConnectAPI).to receive(:client).and_return(mock_client)
        expect(mock_client).to receive(:select_team).with(portal_team_id: team_id, tunes_team_id: nil, team_name: team_name)

        Spaceship::ConnectAPI.select_team(portal_team_id: team_id, team_name: team_name)
      end

      it 'with tunes_team_id' do
        allow(Spaceship::ConnectAPI).to receive(:client).and_return(mock_client)
        expect(mock_client).to receive(:select_team).with(portal_team_id: nil, tunes_team_id: team_id, team_name: team_name)

        Spaceship::ConnectAPI.select_team(tunes_team_id: team_id, team_name: team_name)
      end

      it 'with both portal_team_id and tunes_team_id' do
        allow(Spaceship::ConnectAPI).to receive(:client).and_return(mock_client)
        expect(mock_client).to receive(:select_team).with(portal_team_id: team_id, tunes_team_id: team_id, team_name: team_name)

        Spaceship::ConnectAPI.select_team(portal_team_id: team_id, tunes_team_id: team_id, team_name: team_name)
      end
    end

    it 'without client' do
      allow(Spaceship::ConnectAPI).to receive(:client).and_return(nil)
      expect(mock_client).not_to(receive(:select_team).with(portal_team_id: team_id, tunes_team_id: team_id, team_name: team_name))

      Spaceship::ConnectAPI.select_team(portal_team_id: team_id, tunes_team_id: team_id, team_name: team_name)
    end
  end
end
