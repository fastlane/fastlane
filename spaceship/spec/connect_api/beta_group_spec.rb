describe Spaceship::ConnectAPI::BetaGroup do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::ConnectAPI::Base.client }

  describe '#client' do
    it '#get_beta_groups' do
      response = client.get_beta_groups
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(3)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BetaGroup)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.name).to eq("App Store Connect Users")
      expect(model.created_date).to eq("2018-04-15T18:13:40Z")
      expect(model.is_internal_group).to eq(false)
      expect(model.public_link_enabled).to eq(true)
      expect(model.public_link_id).to eq("abcd1234")
      expect(model.public_link_limit_enabled).to eq(true)
      expect(model.public_link_limit).to eq(10)
      expect(model.public_link).to eq("https://testflight.apple.com/join/abcd1234")
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
        Spaceship::ConnectAPI::BetaGroup.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        Spaceship::ConnectAPI::BetaGroup.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
