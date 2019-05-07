describe Spaceship::ConnectAPI::App do
  App = Spaceship::ConnectAPI::App
  let(:response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/app.json'))
  end
  let(:response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/apps.json'))
  end
  let(:wrong_response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localization.json'))
  end
  let(:wrong_response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localizations.json'))
  end

  context 'parses response' do
    it 'succeeds with object' do
      model = App.parse(response_object)
      expect(model).to be_an_instance_of(App)

      expect(model.id).to eq("123456789")
      expect(model.name).to eq("FastlaneTest")
      expect(model.bundle_id).to eq("com.joshholtz.FastlaneTest")
      expect(model.sku).to eq("SKU_SKU_SKU_SKU")
      expect(model.primary_locale).to eq("en-US")
      expect(model.removed).to eq(false)
      expect(model.is_aag).to eq(false)
    end

    it 'succeeds with array' do
      models = App.parse(response_array)
      expect(models).to be_an_instance_of(Array)
      expect(models.count).to eq(2)
      models.each do |model|
        expect(model).to be_an_instance_of(App)
      end
    end

    it 'fails with wrong type object' do
      expect do
        App.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        App.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
