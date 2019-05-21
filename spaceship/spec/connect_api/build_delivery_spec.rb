describe Spaceship::ConnectAPI::BuildDelivery do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::ConnectAPI::Base.client }

  describe '#client' do
    it '#get_build_deliveries' do
      response = client.get_build_deliveries
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BuildDelivery)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.cf_build_version).to eq("225")
      expect(model.cf_build_short_version_string).to eq("1.1")
      expect(model.platform).to eq("IOS")
      expect(model.uploaded_date).to eq("2019-05-06T20:14:37-07:00")
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
        Spaceship::ConnectAPI::BuildDelivery.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        Spaceship::ConnectAPI::BuildDelivery.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
