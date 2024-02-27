describe Spaceship::ConnectAPI::Provisioning::Client do
  let(:client) { Spaceship::ConnectAPI::Provisioning::Client.new }
  let(:hostname) { Spaceship::ConnectAPI::Provisioning::Client.hostname }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    Spaceship::ConnectAPI.login(username, password, use_portal: true, use_tunes: false)
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
          client.get_bundle_ids
        end
      end
    end

    describe "bundleId Capability" do
      context 'patch_bundle_id_capability' do
        it 'should make a request to turn APP_ATTEST on' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: true, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::APP_ATTEST)
        end
        it 'should make a request to turn APP_ATTEST off' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: false, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::APP_ATTEST)
        end
        it 'should make a request to turn ACCESS_WIFI on' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: true, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::ACCESS_WIFI_INFORMATION)
        end
        it 'should make a request to turn ACCESS_WIFI off' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: false, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::ACCESS_WIFI_INFORMATION)
        end
        it 'should make a request to turn DATA_PROTECTION complete' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: true, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::DATA_PROTECTION,
settings: settings = [{ key: Spaceship::ConnectAPI::BundleIdCapability::Settings::DATA_PROTECTION_PERMISSION_LEVEL, options: [ { key: Spaceship::ConnectAPI::BundleIdCapability::Options::COMPLETE_PROTECTION } ] }])
        end
        it 'should make a request to turn DATA_PROTECTION unless_open' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: true, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::DATA_PROTECTION,
settings: settings = [{ key: Spaceship::ConnectAPI::BundleIdCapability::Settings::DATA_PROTECTION_PERMISSION_LEVEL, options: [ { key: Spaceship::ConnectAPI::BundleIdCapability::Options::PROTECTED_UNLESS_OPEN } ] }])
        end
        it 'should make a request to turn DATA_PROTECTION until_first_auth' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: true, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::DATA_PROTECTION,
settings: settings = [{ key: Spaceship::ConnectAPI::BundleIdCapability::Settings::DATA_PROTECTION_PERMISSION_LEVEL, options: [ { key: Spaceship::ConnectAPI::BundleIdCapability::Options::PROTECTED_UNTIL_FIRST_USER_AUTH } ] }])
        end
        it 'should make a request to turn DATA_PROTECTION off' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: false, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::DATA_PROTECTION)
        end
        it 'should make a request to turn ICLOUD xcode6_compatible' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: true, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::ICLOUD,
settings: settings = [{ key: Spaceship::ConnectAPI::BundleIdCapability::Settings::ICLOUD_VERSION, options: [ { key: Spaceship::ConnectAPI::BundleIdCapability::Options::XCODE_5 } ] }])
        end
        it 'should make a request to turn ICLOUD xcode5_compatible' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: true, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::ICLOUD,
settings: settings = [{ key: Spaceship::ConnectAPI::BundleIdCapability::Settings::ICLOUD_VERSION, options: [ { key: Spaceship::ConnectAPI::BundleIdCapability::Options::XCODE_6 } ] }])
        end
        it 'should make a request to turn ICLOUD off' do
          client.patch_bundle_id_capability(bundle_id_id: "ABCD1234", team_id: "XXXXXXXXXX", enabled: false, capability_type: Spaceship::ConnectAPI::BundleIdCapability::Type::ICLOUD)
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
          client.get_certificates
        end
      end

      context 'get_certificates_for_profile' do
        let(:path) { "profiles/123456789/certificates" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_body(path, params)
          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          client.get_certificates(profile_id: '123456789')
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
          client.get_devices
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
          client.get_profiles
        end
      end
    end
  end
end
