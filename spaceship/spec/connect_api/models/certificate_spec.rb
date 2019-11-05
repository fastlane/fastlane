describe Spaceship::ConnectAPI::Certificate do
  before { Spaceship::Portal.login }

  describe '#client' do
    it '#get_certificates' do
      response = Spaceship::ConnectAPI.get_certificates
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(4)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::Certificate)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.certificate_content).to eq("content")
      expect(model.display_name).to eq("Josh Holtz")
      expect(model.name).to eq("iOS Development: Josh Holtz")
      expect(model.platform).to eq("IOS")
      expect(model.serial_number).to eq("F5A44933E05F97D")
      expect(model.certificate_type).to eq("IOS_DEVELOPMENT")
    end
  end
end
