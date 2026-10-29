describe Spaceship::ConnectAPI::BundleId do
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
    it '#get_bundle_ids' do
      response = Spaceship::ConnectAPI.get_bundle_ids
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BundleId)
      end

      model = response.first
      expect(model.identifier).to eq("com.joshholtz.FastlaneApp")
      expect(model.name).to eq("Fastlane App")
      expect(model.seedId).to eq("972KS36P2U")
      expect(model.platform).to eq("IOS")
    end
  end

  describe '#update_capability' do
    let(:bundle_id) { Spaceship::ConnectAPI.get_bundle_id(bundle_id_id: '123456789').first }

    # A web-session client (no API key) proxies writes through developer.apple.com's own backend.
    # Creating a capability there via the direct POST /v1/bundleIdCapabilities body 409s, demanding
    # an undocumented `capabilities` relationship the direct, API-key-authenticated endpoint never
    # asks for (confirmed live against a real bundle ID - see fastlane/fastlane#30445). So a session
    # client must keep using the long-proven legacy bundleIds PATCH instead.
    context 'authenticated via a web session (no API key)' do
      it 'enables a capability via the legacy bundleIds PATCH, not the direct capability endpoints' do
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/123456789").
          with(body: { "data" => { "type" => "bundleIds", "id" => "123456789", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "972KS36P2U", "teamId" => "123" },
            "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => true, "settings" => [] }, "relationships" => { "capability" => { "data" => { "type" => "capabilities", "id" => "APP_GROUPS" } } } }] } } } }).
          to_return(status: 200, body: ConnectAPIStubbing::Provisioning.read_fixture_file('bundle_id_capabilities_app_groups.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })

        result = bundle_id.update_capability(Spaceship::ConnectAPI::BundleIdCapability::Type::APP_GROUPS, enabled: true)

        expect(result.capability_type).to eq("APP_GROUPS")
        expect(WebMock).not_to have_requested(:post, "https://developer.apple.com/services-account/v1/bundleIdCapabilities")
      end

      it 'disables a capability via the legacy bundleIds PATCH' do
        stub_request(:patch, "https://developer.apple.com/services-account/v1/bundleIds/123456789").
          with(body: { "data" => { "type" => "bundleIds", "id" => "123456789", "attributes" => { "permissions" => { "edit" => true, "delete" => true }, "seedId" => "972KS36P2U", "teamId" => "123" },
            "relationships" => { "bundleIdCapabilities" => { "data" => [{ "type" => "bundleIdCapabilities", "attributes" => { "enabled" => false, "settings" => [] }, "relationships" => { "capability" => { "data" => { "type" => "capabilities", "id" => "APP_GROUPS" } } } }] } } } }).
          to_return(status: 200, body: ConnectAPIStubbing::Provisioning.read_fixture_file('bundle_id_capabilities_empty.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })

        result = bundle_id.update_capability(Spaceship::ConnectAPI::BundleIdCapability::Type::APP_GROUPS, enabled: false)

        expect(result).to be_nil
      end
    end

    context 'authenticated with an App Store Connect API key' do
      before do
        token = Spaceship::ConnectAPI::Token.from_json_file(File.expand_path("../fixtures/asc_key.json", __dir__))
        Spaceship::ConnectAPI.token = token
        stub_request(:get, "https://api.appstoreconnect.apple.com/v1/bundleIds/123456789").
          to_return(status: 200, body: ConnectAPIStubbing::Provisioning.read_fixture_file('bundle_id.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      end

      after do
        Spaceship::ConnectAPI.token = nil
      end

      it 'creates the capability when enabling one that does not exist yet' do
        stub_request(:get, "https://api.appstoreconnect.apple.com/v1/bundleIds/123456789/bundleIdCapabilities").
          to_return(status: 200, body: ConnectAPIStubbing::Provisioning.read_fixture_file('bundle_id_capabilities_empty.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
        stub_request(:post, "https://api.appstoreconnect.apple.com/v1/bundleIdCapabilities").
          with(body: { "data" => { "attributes" => { "capabilityType" => "APP_GROUPS", "settings" => [] }, "type" => "bundleIdCapabilities", "relationships" => { "bundleId" => { "data" => { "type" => "bundleIds", "id" => "123456789" } } } } }).
          to_return(status: 200, body: ConnectAPIStubbing::Provisioning.read_fixture_file('bundle_id_capability_create.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })

        result = bundle_id.update_capability(Spaceship::ConnectAPI::BundleIdCapability::Type::APP_GROUPS, enabled: true)

        expect(result).to be_an_instance_of(Spaceship::ConnectAPI::BundleIdCapability)
      end

      it 'patches the existing capability instead of creating a duplicate when already enabled' do
        stub_request(:get, "https://api.appstoreconnect.apple.com/v1/bundleIds/123456789/bundleIdCapabilities").
          to_return(status: 200, body: ConnectAPIStubbing::Provisioning.read_fixture_file('bundle_id_capabilities_app_groups.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
        stub_request(:patch, "https://api.appstoreconnect.apple.com/v1/bundleIdCapabilities/123456789_APP_GROUPS").
          with(body: { "data" => { "type" => "bundleIdCapabilities", "id" => "123456789_APP_GROUPS", "attributes" => { "enabled" => true, "settings" => [] } } }).
          to_return(status: 200, body: ConnectAPIStubbing::Provisioning.read_fixture_file('bundle_id_capability_create.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })

        result = bundle_id.update_capability(Spaceship::ConnectAPI::BundleIdCapability::Type::APP_GROUPS, enabled: true)

        expect(result.capability_type).to eq("APP_GROUPS")
        expect(WebMock).not_to have_requested(:post, "https://api.appstoreconnect.apple.com/v1/bundleIdCapabilities")
        expect(WebMock).to have_requested(:patch, "https://api.appstoreconnect.apple.com/v1/bundleIdCapabilities/123456789_APP_GROUPS")
      end

      it 'deletes the capability when disabling one that exists' do
        stub_request(:get, "https://api.appstoreconnect.apple.com/v1/bundleIds/123456789/bundleIdCapabilities").
          to_return(status: 200, body: ConnectAPIStubbing::Provisioning.read_fixture_file('bundle_id_capabilities_app_groups.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
        stub_request(:delete, "https://api.appstoreconnect.apple.com/v1/bundleIdCapabilities/123456789_APP_GROUPS").
          to_return(status: 204)

        result = bundle_id.update_capability(Spaceship::ConnectAPI::BundleIdCapability::Type::APP_GROUPS, enabled: false)

        expect(result).to be_nil
        expect(WebMock).to have_requested(:delete, "https://api.appstoreconnect.apple.com/v1/bundleIdCapabilities/123456789_APP_GROUPS")
      end
    end
  end
end
