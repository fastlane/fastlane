describe Spaceship::ConnectAPI::Device do
  before { Spaceship::Portal.login }

  describe '#client' do
    it '#get_devices' do
      response = Spaceship::ConnectAPI.get_devices
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::Device)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.device_class).to eq("IPHONE")
      expect(model.model).to eq("iPhone 8")
      expect(model.name).to eq("Josh's iPhone")
      expect(model.platform).to eq("IOS")
      expect(model.status).to eq("ENABLED")
      expect(model.udid).to eq("184098239048390489012849018")
      expect(model.added_date).to eq("2018-10-10T01:43:27.000+0000")
    end
  end
end
