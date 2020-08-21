describe Spaceship::ConnectAPI::Tunes::Client do
  let(:mock_tunes_client) { double('tunes_client') }
  let(:client) { Spaceship::ConnectAPI::Tunes::Client.new(another_client: mock_tunes_client) }
  let(:hostname) { Spaceship::ConnectAPI::Tunes::Client.hostname }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    allow(mock_tunes_client).to receive(:team_id).and_return("123")
    allow(Spaceship::TunesClient).to receive(:login).and_return(mock_tunes_client)
    Spaceship::ConnectAPI.login(username, password)
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

      return req_mock
    end

    def test_request_body(url, body)
      req_mock = double
      header_mock = double
      expect(req_mock).to receive(:url).with(url)
      expect(req_mock).to receive(:body=).with(JSON.generate(body))
      expect(req_mock).to receive(:headers).and_return(header_mock)
      expect(header_mock).to receive(:[]=).with("Content-Type", "application/json")

      return req_mock
    end

    describe "appStoreVersionReleaseRequests" do
      context 'post_app_store_version_release_request' do
        let(:path) { "appStoreVersionReleaseRequests" }
        let(:app_store_version_id) { "123" }
        let(:body) do
          {
            data: {
              type: "appStoreVersionReleaseRequests",
              relationships: {
                appStoreVersion: {
                  data: {
                    type: "appStoreVersions",
                    id: app_store_version_id
                  }
                }
              }
            }
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          client.post_app_store_version_release_request(app_store_version_id: app_store_version_id)
        end
      end
    end
  end
end
