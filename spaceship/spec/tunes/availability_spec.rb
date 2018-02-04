describe Spaceship::Tunes::Availability do
  before { Spaceship::Tunes.login }
  before { TunesStubbing.itc_stub_app_pricing_intervals }

  let(:client) { Spaceship::AppVersion.client }
  let(:app) { Spaceship::Application.all.first }

  describe "availability" do
    it "inspect works" do
      availability = client.availability(app.apple_id)

      expect(availability.inspect).to include("Tunes::Availability")
    end

    it "correctly parses include_future_territories" do
      availability = client.availability(app.apple_id)

      expect(availability.include_future_territories).to be_truthy
    end

    it "correctly parses the territories" do
      availability = client.availability(app.apple_id)

      expect(availability.territories.length).to eq(2)
      territory_0 = availability.territories[0]

      expect(territory_0).not_to(be_nil)
      expect(territory_0.code).to eq('GB')
      expect(territory_0.currency_code).to eq('GBP')
      expect(territory_0.name).to eq('United Kingdom')
      expect(territory_0.region).to eq('Europe')
      expect(territory_0.region_locale_key).to eq('ITC.region.EUR')
    end
  end

  describe "update_availability!" do
    it "inspect works" do
      TunesStubbing.itc_stub_app_remove_territory
      # currently countries in list are US and GB
      availability = Spaceship::Tunes::Availability.from_territories(["US"])
      availability = client.update_availability!(app.apple_id, availability)

      expect(availability.inspect).to include("Tunes::Availability")
      expect(availability.inspect).to include("Tunes::Territory")
    end

    describe "with countries as strings" do
      it "correctly adds a country" do
        TunesStubbing.itc_stub_app_add_territory

        # currently countries in list are US and GB
        availability = Spaceship::Tunes::Availability.from_territories(["FR", "GB", "US"])
        availability = client.update_availability!(app.apple_id, availability)

        expect(availability.territories.length).to eq(3)
        expect(availability.territories[0].code).to eq("FR")
        expect(availability.territories[1].code).to eq("GB")
        expect(availability.territories[2].code).to eq("US")
      end

      it "correctly removes a country" do
        TunesStubbing.itc_stub_app_remove_territory

        # currently countries in list are US and GB
        availability = Spaceship::Tunes::Availability.from_territories(["US"])
        availability = client.update_availability!(app.apple_id, availability)

        expect(availability.territories.length).to eq(1)
        expect(availability.territories[0].code).to eq("US")
      end
    end

    describe "with countries as Territories" do
      it "correctly adds a country" do
        TunesStubbing.itc_stub_app_add_territory

        # currently countries in list are US and GB
        new_territories_codes = ["FR", "GB", "US"]
        all_territories = client.supported_territories
        territories = all_territories.select { |territory| new_territories_codes.include?(territory.code) }

        availability = Spaceship::Tunes::Availability.from_territories(territories)
        availability = client.update_availability!(app.apple_id, availability)

        expect(availability.territories.length).to eq(3)
        expect(availability.territories[0].code).to eq("FR")
        expect(availability.territories[1].code).to eq("GB")
        expect(availability.territories[2].code).to eq("US")
      end

      it "correctly removes a country" do
        TunesStubbing.itc_stub_app_remove_territory

        # currently countries in list are US and GB
        new_territories_codes = ["US"]
        all_territories = client.supported_territories
        territories = all_territories.select { |territory| new_territories_codes.include?(territory.code) }

        availability = Spaceship::Tunes::Availability.from_territories(territories)
        availability = client.update_availability!(app.apple_id, availability)

        expect(availability.territories.length).to eq(1)
        expect(availability.territories[0].code).to eq("US")
      end
    end

    it "correctly unincludes all future territories" do
      TunesStubbing.itc_stub_app_uninclude_future_territories

      # currently countries in list are US and GB
      availability = Spaceship::Tunes::Availability.from_territories(["GB", "US"], include_future_territories: false)
      availability = client.update_availability!(app.apple_id, availability)

      expect(availability.include_future_territories).to be_falsey
    end
  end
end
