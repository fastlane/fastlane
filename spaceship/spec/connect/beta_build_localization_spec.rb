describe Spaceship::ConnectAPI::BetaBuildLocalization do
  BetaBuildLocalization = Spaceship::ConnectAPI::BetaBuildLocalization
  let(:response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_build_localization.json'))
  end
  let(:response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_build_localizations.json'))
  end
  let(:wrong_response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localization.json'))
  end
  let(:wrong_response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localizations.json'))
  end

  context 'parses response' do
    it 'succeeds with object' do
      model = BetaBuildLocalization.parse(response_object)
      expect(model).to be_an_instance_of(BetaBuildLocalization)

      expect(model.id).to eq("123456789")
      expect(model.whats_new).to eq("so many en-us things2")
      expect(model.locale).to eq("en-US")
    end

    it 'succeeds with array' do
      models = BetaBuildLocalization.parse(response_array)
      expect(models).to be_an_instance_of(Array)
      expect(models.count).to eq(2)
      models.each do |model|
        expect(model).to be_an_instance_of(BetaBuildLocalization)
      end
    end

    it 'fails with wrong type object' do
      expect do
        BetaBuildLocalization.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        BetaBuildLocalization.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
