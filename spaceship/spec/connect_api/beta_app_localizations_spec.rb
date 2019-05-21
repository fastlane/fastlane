describe Spaceship::ConnectAPI::BetaAppLocalization do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::ConnectAPI::Base.client }

  describe '#client' do
    it 'succeeds with object' do
      response = client.get_beta_app_localizations

      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)
      expect(response.count).to eq(1)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BetaAppLocalization)
      end

      model = response.first

      expect(model.id).to eq("123456789")
      expect(model.feedback_email).to eq("email@email.com")
      expect(model.marketing_url).to eq("https://fastlane.tools/marketing")
      expect(model.privacy_policy_url).to eq("https://fastlane.tools/policy")
      expect(model.tv_os_privacy_policy).to eq(nil)
      expect(model.description).to eq("This is a description of my app")
      expect(model.locale).to eq("en-US")
    end
  end

  describe 'parses response' do
    let(:wrong_response_object) do
      JSON.parse(File.read('./spaceship/spec/connect_api/fixtures/app.json'))
    end
    let(:wrong_response_array) do
      JSON.parse(File.read('./spaceship/spec/connect_api/fixtures/apps.json'))
    end

    it 'fails with wrong type object' do
      expect do
        Spaceship::ConnectAPI::BetaAppLocalization.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        Spaceship::ConnectAPI::BetaAppLocalization.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
