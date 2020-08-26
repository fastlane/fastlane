describe Spaceship::ConnectAPI::Provisioning::Client do
  let(:client) { Spaceship::ConnectAPI::Provisioning::Client.instance }
  let(:hostname) { Spaceship::ConnectAPI::Provisioning::Client.hostname }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    Spaceship::Portal.login(username, password)
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

      encoded_params = Faraday::NestedParamsEncoder.encode(body)
      encoded_body = { "urlEncodedQueryParams" => encoded_params, "teamId" => Spaceship::Portal.client.team_id }

      expect(req_mock).to receive(:url).with(url)
      expect(req_mock).to receive(:body=).with(JSON.generate(encoded_body))
      expect(req_mock).to receive(:headers).and_return(header_mock).exactly(3).times

      expect(header_mock).to receive(:[]=).with("X-Requested-With", "XMLHttpRequest")
      expect(header_mock).to receive(:[]=).with("X-HTTP-Method-Override", "GET")
      expect(header_mock).to receive(:[]=).with("Content-Type", "application/vnd.api+json")

      return req_mock
    end

    describe "bundleIds" do
      context 'get_bundle_ids' do
        let(:path) { "bundleIds" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_body(path, params)
          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          Spaceship::ConnectAPI.get_bundle_ids
        end
      end
    end

    describe "certificates" do
      context 'get_certificates' do
        let(:path) { "certificates" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_body(path, params)
          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          Spaceship::ConnectAPI.get_certificates
        end
      end
    end

    describe "devices" do
      context 'get_devices' do
        let(:path) { "devices" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_body(path, params)
          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          Spaceship::ConnectAPI.get_devices
        end
      end
    end

    describe "profiles" do
      context 'get_profiles' do
        let(:path) { "profiles" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_body(path, params)
          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          Spaceship::ConnectAPI.get_profiles
        end
      end
    end
  end
end
