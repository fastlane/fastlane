describe Spaceship::ConnectAPI::Build do
  Build = Spaceship::ConnectAPI::Build
  let(:response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/build.json'))
  end
  let(:response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/builds.json'))
  end
  let(:wrong_response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localization.json'))
  end
  let(:wrong_response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localizations.json'))
  end

  context 'parses response' do
    it 'succeeds with object' do
      model = Build.parse(response_object)
      expect(model).to be_an_instance_of(Build)

      expect(model.id).to eq("123456789")
      expect(model.version).to eq("225")
      expect(model.uploaded_date).to eq("2019-04-30T17:16:21-07:00")
      expect(model.expiration_date).to eq("2019-07-29T17:16:21-07:00")
      expect(model.expired).to eq(false)
      expect(model.min_os_version).to eq("10.3")
      expect(model.icon_asset_token).to eq({
        "templateUrl" => "https://is3-ssl.mzstatic.com/image/thumb/Purple/v4/97/f3/8a/97f38a96-38df-b4a0-8e93-cbb7c1f5ecd8/Icon-83.5@2x.png.png/{w}x{h}bb.{f}",
        "width" => 167,
        "height" => 167
      })
      expect(model.processing_state).to eq("VALID")
      expect(model.uses_non_exempt_encryption).to eq(false)
      expect(model.qc_state).to eq("BETA_INTERNAL_TESTING")
    end

    it 'succeeds with array' do
      models = Build.parse(response_array)
      expect(models).to be_an_instance_of(Array)
      expect(models.count).to eq(2)
      models.each do |model|
        expect(model).to be_an_instance_of(Build)
      end
    end

    it 'fails with wrong type object' do
      expect do
        Build.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        Build.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
