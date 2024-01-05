describe Spaceship::Tunes::Territory do
  before { Spaceship::Tunes.login }

  let(:client) { Spaceship::AppVersion.client }

  describe "supported_territories" do
    it "inspect works" do
      supported_territories = client.supported_territories

      expect(supported_territories.inspect).to include("Tunes::Territory")
    end

    it "correctly creates all territories" do
      supported_territories = client.supported_territories

      expect(supported_territories.length).to eq(155)
    end

    it "correctly parses the territories" do
      territory_0 = client.supported_territories[0]

      expect(territory_0).not_to(be_nil)
      expect(territory_0.code).to eq('AL')
      expect(territory_0.currency_code).to eq('USD')
      expect(territory_0.name).to eq('Albania')
      expect(territory_0.region).to eq('Europe')
      expect(territory_0.region_locale_key).to eq('ITC.region.EUR')
    end
  end
end
