describe Spaceship::ConnectAPI::BetaAppReviewSubmission do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::ConnectAPI::Base.client }

  describe '#client' do
    it '#get_beta_app_review_submissions' do
      response = client.get_beta_app_review_submissions
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BetaAppReviewSubmission)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.beta_review_state).to eq("APPROVED")
    end
  end
end
