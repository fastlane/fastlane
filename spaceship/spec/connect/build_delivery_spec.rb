describe Spaceship::ConnectAPI::BuildDelivery do
  BuildDelivery = Spaceship::ConnectAPI::BuildDelivery
  let(:response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/build_delivery.json'))
  end
  let(:response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/build_deliveries.json'))
  end
  let(:wrong_response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localization.json'))
  end
  let(:wrong_response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localizations.json'))
  end

  context 'parses response' do
    it 'succeeds with object' do
      model = BuildDelivery.parse(response_object)
      expect(model).to be_an_instance_of(BuildDelivery)

      expect(model.id).to eq("123456789")
      expect(model.cf_build_version).to eq("225")
      expect(model.cf_build_short_version_string).to eq("1.1")
      expect(model.platform).to eq("IOS")
      expect(model.uploaded_date).to eq("2019-05-06T20:14:37-07:00")
    end

    it 'succeeds with array' do
      models = BuildDelivery.parse(response_array)
      expect(models).to be_an_instance_of(Array)
      expect(models.count).to eq(1)
      models.each do |model|
        expect(model).to be_an_instance_of(BuildDelivery)
      end
    end

    it 'fails with wrong type object' do
      expect do
        BuildDelivery.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        BuildDelivery.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
