describe Spaceship::ConnectAPI::PreReleaseVersion do
  PreReleaseVersion = Spaceship::ConnectAPI::PreReleaseVersion
  let(:response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/pre_release_version.json'))
  end
  let(:response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/pre_release_versions.json'))
  end
  let(:wrong_response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localization.json'))
  end
  let(:wrong_response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localizations.json'))
  end

  context 'parses response' do
    it 'succeeds with object' do
      model = PreReleaseVersion.parse(response_object)
      expect(model).to be_an_instance_of(PreReleaseVersion)

      expect(model.id).to eq("123456789")
      expect(model.version).to eq("3.3.3")
      expect(model.platform).to eq("IOS")
    end

    it 'succeeds with array' do
      models = PreReleaseVersion.parse(response_array)
      expect(models).to be_an_instance_of(Array)
      expect(models.count).to eq(2)
      models.each do |model|
        expect(model).to be_an_instance_of(PreReleaseVersion)
      end
    end

    it 'fails with wrong type object' do
      expect do
        PreReleaseVersion.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        PreReleaseVersion.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
