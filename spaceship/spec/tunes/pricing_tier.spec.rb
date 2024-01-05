describe Spaceship::Tunes::PricingTier do
  before { Spaceship::Tunes.login }

  let(:client) { Spaceship::AppVersion.client }

  describe "Pricing Tiers" do
    it "inspect works" do
      pricing_tiers = client.pricing_tiers

      expect(pricing_tiers.inspect).to include("Tunes::PricingTier")
      expect(pricing_tiers.inspect).to include("Tunes::PricingInfo")
    end

    it "correctly creates all pricing tiers including pricing infos" do
      pricing_tiers = client.pricing_tiers
      tier_1 = client.pricing_tiers[1]

      expect(pricing_tiers.length).to eq(95)
      expect(tier_1.pricing_info.length).to eq(48)
    end

    it "correctly parses the pricing tiers" do
      tier_1 = client.pricing_tiers[1]

      expect(tier_1).not_to(be_nil)
      expect(tier_1.tier_stem).to eq('1')
      expect(tier_1.tier_name).to eq('Tier 1')
      expect(tier_1.pricing_info).not_to(be_empty)
    end

    it "correctly parses the pricing information" do
      tier_1_first_pricing_info = client.pricing_tiers[1].pricing_info[0]

      expect(tier_1_first_pricing_info.country).to eq('United States')
      expect(tier_1_first_pricing_info.country_code).to eq('US')
      expect(tier_1_first_pricing_info.currency_symbol).to eq('$')
      expect(tier_1_first_pricing_info.wholesale_price).to eq(0.7)
      expect(tier_1_first_pricing_info.retail_price).to eq(0.99)
      expect(tier_1_first_pricing_info.f_retail_price).to eq('$0.99')
      expect(tier_1_first_pricing_info.f_wholesale_price).to eq('$0.70')
    end
  end
end
