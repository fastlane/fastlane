describe Spaceship::ConnectAPI::PreReleaseVersion do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::ConnectAPI::Base.client }

  describe '#client' do
    it '#get_pre_release_versions' do
      response = client.get_pre_release_versions
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

  describe 'parses response' do
    let(:wrong_response_object) do
      JSON.parse(File.read('./spaceship/spec/connect_api/fixtures/beta_app_localization.json'))
    end
    let(:wrong_response_array) do
      JSON.parse(File.read('./spaceship/spec/connect_api/fixtures/beta_app_localizations.json'))
    end

    it 'fails with wrong type object' do
      expect do
        Spaceship::ConnectAPI::PreReleaseVersion.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        Spaceship::ConnectAPI::PreReleaseVersion.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
