describe Spaceship::ConnectAPI::BetaAppReviewDetail do
  BetaAppReviewDetail = Spaceship::ConnectAPI::BetaAppReviewDetail
  let(:response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_review_detail.json'))
  end
  let(:response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_review_details.json'))
  end
  let(:wrong_response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localization.json'))
  end
  let(:wrong_response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localizations.json'))
  end

  context 'parses response' do
    it 'succeeds with object' do
      model = BetaAppReviewDetail.parse(response_object)
      expect(model).to be_an_instance_of(BetaAppReviewDetail)

      expect(model.id).to eq("123456789")
      expect(model.contact_first_name).to eq("Connect")
      expect(model.contact_last_name).to eq("API")
      expect(model.contact_phone).to eq("5558674309")
      expect(model.contact_email).to eq("email@email.com")
      expect(model.demo_account_name).to eq("username")
      expect(model.demo_account_password).to eq("password")
      expect(model.demo_account_required).to eq(true)
      expect(model.notes).to eq("this is review notes")
    end

    it 'succeeds with array' do
      models = BetaAppReviewDetail.parse(response_array)
      expect(models).to be_an_instance_of(Array)
      expect(models.count).to eq(1)
      models.each do |model|
        expect(model).to be_an_instance_of(BetaAppReviewDetail)
      end
    end

    it 'fails with wrong type object' do
      expect do
        BetaAppReviewDetail.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        BetaAppReviewDetail.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
