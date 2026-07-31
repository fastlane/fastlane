describe Spaceship::ConnectAPI::Users::Client do
  let(:mock_tunes_client) { double('tunes_client') }
  let(:client) { Spaceship::ConnectAPI::Users::Client.new(another_client: mock_tunes_client) }
  let(:hostname) { Spaceship::ConnectAPI::Users::Client.hostname }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    allow(mock_tunes_client).to receive(:team_id).and_return("123")
    allow(mock_tunes_client).to receive(:select_team)
    allow(mock_tunes_client).to receive(:csrf_tokens)
    allow(Spaceship::TunesClient).to receive(:login).and_return(mock_tunes_client)
    Spaceship::ConnectAPI.login(username, password, use_portal: false, use_tunes: true)
  end

  context 'sends api request' do
    before(:each) do
      allow(client).to receive(:handle_response)
    end

    def test_request_params(url, params)
      req_mock = double
      options_mock = double

      allow(req_mock).to receive(:headers).and_return({})

      expect(req_mock).to receive(:url).with(url)
      expect(req_mock).to receive(:params=).with(params)
      expect(req_mock).to receive(:options).and_return(options_mock)
      expect(options_mock).to receive(:params_encoder=).with(Faraday::NestedParamsEncoder)
      allow(req_mock).to receive(:status)

      return req_mock
    end

    def test_request_body(url, body)
      req_mock = double
      header_mock = double
      expect(req_mock).to receive(:url).with(url)
      expect(req_mock).to receive(:body=).with(JSON.generate(body))
      expect(req_mock).to receive(:headers).and_return(header_mock)
      expect(header_mock).to receive(:[]=).with("Content-Type", "application/json")
      allow(req_mock).to receive(:status)

      return req_mock
    end

    def test_request(url)
      req_mock = double
      expect(req_mock).to receive(:url).with(url)
      allow(req_mock).to receive(:status)

      return req_mock
    end

    describe "users" do
      context 'get_users' do
        let(:path) { "v1/users" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock).and_return(req_mock)
          client.get_users
        end
      end

      context 'patch_user' do
        let(:user_id) { "123" }
        let(:all_apps_visible) { false }
        let(:provisioning_allowed) { true }
        let(:roles) { ["ADMIN"] }
        let(:path) { "v1/users/#{user_id}" }
        let(:app_ids) { ["456", "789"] }
        let(:body) do
          {
            data: {
              type: 'users',
              id: user_id,
              attributes: {
                allAppsVisible: all_apps_visible,
                provisioningAllowed: provisioning_allowed,
                roles: roles
              },
              relationships: {
                visibleApps: {
                  data: app_ids.map do |app_id|
                    {
                      type: "apps",
                      id: app_id
                    }
                  end
                }
              }
            }
          }
        end

        it 'succeeds with list of apps' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:patch).and_yield(req_mock).and_return(req_mock)
          client.patch_user(user_id: user_id, all_apps_visible: all_apps_visible, provisioning_allowed: provisioning_allowed, roles: roles, visible_app_ids: app_ids)
        end

        it 'succeeds with all apps' do
          body_all_apps = body.clone
          body_all_apps[:data][:attributes][:allAppsVisible] = true
          body_all_apps[:data].delete(:relationships)

          url = path
          req_mock = test_request_body(url, body_all_apps)

          expect(client).to receive(:request).with(:patch).and_yield(req_mock).and_return(req_mock)
          client.patch_user(user_id: user_id, all_apps_visible: true, provisioning_allowed: provisioning_allowed, roles: roles, visible_app_ids: app_ids)
        end
      end

      context 'delete_user' do
        let(:user_id) { "123" }
        let(:path) { "v1/users/#{user_id}" }

        it 'succeeds' do
          req_mock = test_request(path)
          expect(client).to receive(:request).with(:delete).and_yield(req_mock).and_return(req_mock)
          client.delete_user(user_id: user_id)
        end
      end

      context 'post_user_visible_apps' do
        let(:user_id) { "123" }
        let(:path) { "v1/users/#{user_id}/relationships/visibleApps" }
        let(:app_ids) { ["456", "789"] }
        let(:body) do
          {
            data: app_ids.map do |app_id|
              {
                type: "apps",
                id: app_id
              }
            end
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:post).and_yield(req_mock).and_return(req_mock)
          client.post_user_visible_apps(user_id: user_id, app_ids: app_ids)
        end
      end

      context 'patch_user_visible_apps' do
        let(:user_id) { "123" }
        let(:path) { "v1/users/#{user_id}/relationships/visibleApps" }
        let(:app_ids) { ["456", "789"] }
        let(:body) do
          {
            data: app_ids.map do |app_id|
              {
                type: "apps",
                id: app_id
              }
            end
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:patch).and_yield(req_mock).and_return(req_mock)
          client.patch_user_visible_apps(user_id: user_id, app_ids: app_ids)
        end
      end

      context 'delete_user_visible_apps' do
        let(:user_id) { "123" }
        let(:path) { "v1/users/#{user_id}/relationships/visibleApps" }
        let(:app_ids) { ["456", "789"] }
        let(:body) do
          {
            data: app_ids.map do |app_id|
              {
                type: "apps",
                id: app_id
              }
            end
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:delete).and_yield(req_mock).and_return(req_mock)
          client.delete_user_visible_apps(user_id: user_id, app_ids: app_ids)
        end
      end

      context 'get_user_visible_apps' do
        let(:user_id) { "42" }
        let(:path) { "v1/users/#{user_id}/visibleApps" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock).and_return(req_mock)
          client.get_user_visible_apps(user_id: user_id)
        end
      end
    end

    describe "user_invitations" do
      context 'get_user_invitations' do
        let(:path) { "v1/userInvitations" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock).and_return(req_mock)
          client.get_user_invitations
        end
      end

      context 'post_user_invitation' do
        let(:path) { "v1/userInvitations" }
        let(:attributes) {
          {
            email: "test@example.com",
            firstName: "Firstname",
            lastName: "Lastname",
            roles: [],
            provisioningAllowed: true,
            allAppsVisible: false
          }
        }
        let(:visible_app_ids) { ["123", "456"] }
        let(:body) do
          {
            data: {
              type: "userInvitations",
              attributes: attributes,
              relationships: {
                visibleApps: {
                  data: visible_app_ids.map do |id|
                    {
                      id: id,
                      type: "apps"
                    }
                  end
                }
              }
            }
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:post).and_yield(req_mock).and_return(req_mock)
          client.post_user_invitation(
            email: "test@example.com",
            first_name: "Firstname",
            last_name: "Lastname",
            roles: [],
            provisioning_allowed: true,
            all_apps_visible: false,
            visible_app_ids: ["123", "456"]
          )
        end
      end

      context 'delete_user_invitation' do
        let(:invitation_id) { "123" }
        let(:path) { "v1/userInvitations/#{invitation_id}" }

        it 'succeeds' do
          req_mock = test_request(path)
          expect(client).to receive(:request).with(:delete).and_yield(req_mock).and_return(req_mock)
          client.delete_user_invitation(user_invitation_id: invitation_id)
        end
      end

      context 'get_user_invitation_visible_apps' do
        let(:invitation_id) { "42" }
        let(:path) { "v1/userInvitations/#{invitation_id}/visibleApps" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock).and_return(req_mock)
          client.get_user_invitation_visible_apps(user_invitation_id: invitation_id)
        end
      end
    end
  end
end
