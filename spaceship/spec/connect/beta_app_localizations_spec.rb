describe Spaceship::ConnectAPI::BetaAppLocalization do
  BetaAppLocalization = Spaceship::ConnectAPI::BetaAppLocalization
  let(:response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localization.json'))
  end
  let(:response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localizations.json'))
  end
  let(:wrong_response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/app.json'))
  end
  let(:wrong_response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/apps.json'))
  end

  context 'parses response' do
    it 'succeeds with object' do
      model = BetaAppLocalization.parse(response_object)
      expect(model).to be_an_instance_of(BetaAppLocalization)

      expect(model.id).to eq("123456789")
      expect(model.feedback_email).to eq("email@email.com")
      expect(model.marketing_url).to eq("https://fastlane.tools/marketing")
      expect(model.privacy_policy_url).to eq("https://fastlane.tools/policy")
      expect(model.tv_os_privacy_policy).to eq(nil)
      expect(model.description).to eq("This is a description of my app")
      expect(model.locale).to eq("en-US")
    end

    it 'succeeds with array' do
      models = BetaAppLocalization.parse(response_array)
      expect(models).to be_an_instance_of(Array)
      expect(models.count).to eq(1)
      models.each do |model|
        expect(model).to be_an_instance_of(BetaAppLocalization)
      end
    end

    it 'fails with wrong type object' do
      expect do
        BetaAppLocalization.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        BetaAppLocalization.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
