describe Spaceship::ConnectAPI::BetaGroup do
  BetaGroup = Spaceship::ConnectAPI::BetaGroup
  let(:response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_group.json'))
  end
  let(:response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_groups.json'))
  end
  let(:wrong_response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localization.json'))
  end
  let(:wrong_response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localizations.json'))
  end

  context 'parses response' do
    it 'succeeds with object' do
      model = BetaGroup.parse(response_object)
      expect(model).to be_an_instance_of(BetaGroup)

      expect(model.id).to eq("123456789")
      expect(model.name).to eq("Spacey Group")
      expect(model.created_date).to eq("2018-04-15T18:13:40Z")
      expect(model.is_internal_group).to eq(false)
      expect(model.public_link_enabled).to eq(true)
      expect(model.public_link_id).to eq("abcd1234")
      expect(model.public_link_limit_enabled).to eq(true)
      expect(model.public_link_limit).to eq(10)
      expect(model.public_link).to eq("https://testflight.apple.com/join/abcd1234")
    end

    it 'succeeds with array' do
      models = BetaGroup.parse(response_array)
      expect(models).to be_an_instance_of(Array)
      expect(models.count).to eq(3)
      models.each do |model|
        expect(model).to be_an_instance_of(BetaGroup)
      end
    end

    it 'fails with wrong type object' do
      expect do
        BetaGroup.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        BetaGroup.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
