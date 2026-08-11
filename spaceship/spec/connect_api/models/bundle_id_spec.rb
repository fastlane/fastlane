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

    it 'creates the capability when enabling one that does not exist yet' do
      result = bundle_id.update_capability(Spaceship::ConnectAPI::BundleIdCapability::Type::APP_GROUPS, enabled: true)
      expect(result).to be_an_instance_of(Spaceship::ConnectAPI::BundleIdCapability)
    end

    it 'does not send a create request when the capability is already enabled' do
      stub_request(:post, "https://developer.apple.com/services-account/v1/bundleIds/123456789/bundleIdCapabilities").
        to_return(status: 200, body: ConnectAPIStubbing::Provisioning.read_fixture_file('bundle_id_capabilities_app_groups.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })

      result = bundle_id.update_capability(Spaceship::ConnectAPI::BundleIdCapability::Type::APP_GROUPS, enabled: true)

      expect(result.capability_type).to eq("APP_GROUPS")
      expect(WebMock).not_to have_requested(:post, "https://developer.apple.com/services-account/v1/bundleIdCapabilities")
    end

    it 'deletes the capability when disabling one that exists' do
      stub_request(:post, "https://developer.apple.com/services-account/v1/bundleIds/123456789/bundleIdCapabilities").
        to_return(status: 200, body: ConnectAPIStubbing::Provisioning.read_fixture_file('bundle_id_capabilities_app_groups.json'), headers: { 'Content-Type' => 'application/vnd.api+json' })
      stub_request(:post, "https://developer.apple.com/services-account/v1/bundleIdCapabilities/123456789_APP_GROUPS").
        with(headers: { 'X-Http-Method-Override' => 'DELETE' }).
        to_return(status: 204)

      result = bundle_id.update_capability(Spaceship::ConnectAPI::BundleIdCapability::Type::APP_GROUPS, enabled: false)

      expect(result).to be_nil
      expect(WebMock).to have_requested(:post, "https://developer.apple.com/services-account/v1/bundleIdCapabilities/123456789_APP_GROUPS").
        with(headers: { 'X-Http-Method-Override' => 'DELETE' })
    end
  end
end
