describe Spaceship::ConnectAPI::BuildBetaDetail do
  BuildBetaDetail = Spaceship::ConnectAPI::BuildBetaDetail
  let(:response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/build_beta_detail.json'))
  end
  let(:response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/build_beta_details.json'))
  end
  let(:wrong_response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localization.json'))
  end
  let(:wrong_response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localizations.json'))
  end

  context 'parses response' do
    it 'succeeds with object' do
      model = BuildBetaDetail.parse(response_object)
      expect(model).to be_an_instance_of(BuildBetaDetail)

      expect(model.id).to eq("123456789")
      expect(model.auto_notify_enabled).to eq(false)
      expect(model.did_notify).to eq(false)
      expect(model.internal_build_state).to eq("IN_BETA_TESTING")
      expect(model.external_build_state).to eq("READY_FOR_BETA_SUBMISSION")
    end

    it 'succeeds with array' do
      models = BuildBetaDetail.parse(response_array)
      expect(models).to be_an_instance_of(Array)
      expect(models.count).to eq(1)
      models.each do |model|
        expect(model).to be_an_instance_of(BuildBetaDetail)
      end
    end

    it 'fails with wrong type object' do
      expect do
        BuildBetaDetail.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        BuildBetaDetail.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
