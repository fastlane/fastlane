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

  describe '.all' do
    let(:client) { double('client') }
    let(:response) { double('response', all_pages: []) }

    it 'passes limit and sort to get_bundle_ids' do
      expect(client).to receive(:get_bundle_ids).with(
        filter: {},
        includes: nil,
        fields: nil,
        limit: 10,
        sort: "name"
      ).and_return(response)

      Spaceship::ConnectAPI::BundleId.all(client: client, limit: 10, sort: "name")
    end

    it 'defaults limit to MAX_OBJECTS_PER_PAGE_LIMIT' do
      expect(client).to receive(:get_bundle_ids).with(
        hash_including(limit: Spaceship::ConnectAPI::MAX_OBJECTS_PER_PAGE_LIMIT, sort: nil)
      ).and_return(response)

      Spaceship::ConnectAPI::BundleId.all(client: client)
    end
  end
end
