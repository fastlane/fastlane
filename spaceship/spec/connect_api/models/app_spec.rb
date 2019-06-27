describe Spaceship::ConnectAPI::App do
  before { Spaceship::Tunes.login }

  describe '#Spaceship::ConnectAPI' do
    it '#get_apps' do
      response = Spaceship::ConnectAPI.get_apps
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::App)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.name).to eq("FastlaneTest")
      expect(model.bundle_id).to eq("com.joshholtz.FastlaneTest")
      expect(model.sku).to eq("SKU_SKU_SKU_SKU")
      expect(model.primary_locale).to eq("en-US")
      expect(model.removed).to eq(false)
      expect(model.is_aag).to eq(false)
    end

    it 'gets by app id' do
      response = Spaceship::ConnectAPI.get_app(app_id: "123456789")
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::App)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.bundle_id).to eq("com.joshholtz.FastlaneTest")
    end
  end

  describe "App object" do
    it 'finds app by bundle id' do
      model = Spaceship::ConnectAPI::App.find("com.joshholtz.FastlaneTest")
      expect(model.bundle_id).to eq("com.joshholtz.FastlaneTest")
    end
  end
end
