describe Spaceship::ConnectAPI::BetaAppReviewSubmission do
  BetaAppReviewSubmission = Spaceship::ConnectAPI::BetaAppReviewSubmission
  let(:response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_review_submission.json'))
  end
  let(:response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_review_submissions.json'))
  end
  let(:wrong_response_object) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localization.json'))
  end
  let(:wrong_response_array) do
    JSON.parse(File.read('./spaceship/spec/connect/fixtures/beta_app_localizations.json'))
  end

  context 'parses response' do
    it 'succeeds with object' do
      model = BetaAppReviewSubmission.parse(response_object)
      expect(model).to be_an_instance_of(BetaAppReviewSubmission)

      expect(model.id).to eq("123456789")
      expect(model.beta_review_state).to eq("APPROVED")
    end

    it 'succeeds with array' do
      models = BetaAppReviewSubmission.parse(response_array)
      expect(models).to be_an_instance_of(Array)
      expect(models.count).to eq(1)
      models.each do |model|
        expect(model).to be_an_instance_of(BetaAppReviewSubmission)
      end
    end

    it 'fails with wrong type object' do
      expect do
        BetaAppReviewSubmission.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        BetaAppReviewSubmission.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
