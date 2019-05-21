describe Spaceship::ConnectAPI::BetaAppReviewDetail do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::ConnectAPI::Base.client }

  describe '#client' do
    it '#get_beta_app_review_detail' do
      response = client.get_beta_app_review_detail
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BetaAppReviewDetail)
      end

      model = response.first
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
  end

  describe "parses response" do
    let(:wrong_response_object) do
      JSON.parse(File.read('./spaceship/spec/connect_api/fixtures/beta_app_localization.json'))
    end
    let(:wrong_response_array) do
      JSON.parse(File.read('./spaceship/spec/connect_api/fixtures/beta_app_localizations.json'))
    end

    it 'fails with wrong type object' do
      expect do
        Spaceship::ConnectAPI::BetaAppReviewDetail.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        Spaceship::ConnectAPI::BetaAppReviewDetail.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
