describe Spaceship::ConnectAPI::PreReleaseVersion do
  before { Spaceship::Tunes.login }

  describe '#Spaceship::ConnectAPI' do
    it '#get_pre_release_versions' do
      response = Spaceship::ConnectAPI.get_pre_release_versions
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::PreReleaseVersion)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.version).to eq("3.3.3")
      expect(model.platform).to eq("IOS")
    end
  end
end
