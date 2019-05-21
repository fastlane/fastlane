describe Spaceship::ConnectAPI::BuildBetaDetail do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::ConnectAPI::Base.client }

  describe '#client' do
    it '#get_build_beta_details' do
      response = client.get_build_beta_details
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BuildBetaDetail)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.auto_notify_enabled).to eq(false)
      expect(model.did_notify).to eq(false)
      expect(model.internal_build_state).to eq("IN_BETA_TESTING")
      expect(model.external_build_state).to eq("READY_FOR_BETA_SUBMISSION")
    end
  end

  describe 'parses response' do
    let(:wrong_response_object) do
      JSON.parse(File.read('./spaceship/spec/connect_api/fixtures/beta_app_localization.json'))
    end
    let(:wrong_response_array) do
      JSON.parse(File.read('./spaceship/spec/connect_api/fixtures/beta_app_localizations.json'))
    end

    it 'fails with wrong type object' do
      expect do
        Spaceship::ConnectAPI::BuildBetaDetail.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        Spaceship::ConnectAPI::BuildBetaDetail.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
