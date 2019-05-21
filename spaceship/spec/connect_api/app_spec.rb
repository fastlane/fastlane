describe Spaceship::ConnectAPI::App do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::ConnectAPI::Base.client }

  describe '#client' do
    it '#get_apps' do
      response = client.get_apps
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
      response = client.get_app(app_id: "123456789")
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

  describe 'parses response' do
    let(:wrong_response_object) do
      JSON.parse(File.read('./spaceship/spec/connect_api/fixtures/beta_app_localization.json'))
    end
    let(:wrong_response_array) do
      JSON.parse(File.read('./spaceship/spec/connect_api/fixtures/beta_app_localizations.json'))
    end

    it 'fails with wrong type object' do
      expect do
        Spaceship::ConnectAPI::App.parse(wrong_response_object)
      end.to raise_error(/not of type/)
    end

    it 'fails with wrong type array of objects' do
      expect do
        Spaceship::ConnectAPI::App.parse(wrong_response_array)
      end.to raise_error(/not of type/)
    end
  end
end
