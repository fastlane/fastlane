describe Spaceship::ConnectAPI::BundleId do
  before { Spaceship::Portal.login }

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
end
