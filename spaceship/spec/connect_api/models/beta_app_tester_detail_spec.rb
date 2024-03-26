describe Spaceship::ConnectAPI::BetaAppTesterDetail do
  before { Spaceship::Tunes.login }

  describe '#Spaceship::ConnectAPI' do
    it '#get_beta_app_tester_detail' do
      response = Spaceship::ConnectAPI.get_beta_app_tester_detail(app_id: "123456789")
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BetaAppTesterDetail)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.maxInternalTesters).to eq(100)
      expect(model.maxExternalTesters).to eq(10_000)
      expect(model.maxInternalGroups).to eq(100)
      expect(model.maxExternalGroups).to eq(200)
      expect(model.currentInternalTesters).to eq(1)
      expect(model.currentExternalTesters).to eq(9725)
      expect(model.currentDeletedTesters).to eq(1680)
    end
  end
end
