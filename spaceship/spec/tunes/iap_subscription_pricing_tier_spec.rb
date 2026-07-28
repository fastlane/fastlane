describe Spaceship::Tunes::IAPSubscriptionPricingTier do
  before { TunesStubbing.itc_stub_iap }
  include_examples "common spaceship login"

  let(:client) { Spaceship::AppVersion.client }
  let(:app) { Spaceship::Application.all.find { |a| a.apple_id == "898536088" } }
  let(:pricing_tiers) { client.subscription_pricing_tiers(app.apple_id) }

  describe "In-App-Purchase Subscription Pricing Tier" do
    subject { pricing_tiers }

    it "inspect works" do
      expect(subject.inspect).to include("Tunes::IAPSubscriptionPricingTier")
      expect(subject.inspect).to include("Tunes::IAPSubscriptionPricingInfo")
    end

    it "correctly creates all 200 subscription pricing tiers" do
      expect(subject).to all(be_an(Spaceship::Tunes::IAPSubscriptionPricingTier))
      expect(subject.size).to eq(200)
    end

    describe "Subscription Pricing Tier Info" do
      subject { pricing_tiers.flat_map(&:pricing_info) }

      it "correctly creates all 155 pricing infos for each country" do
        expect(subject).to all(be_an(Spaceship::Tunes::IAPSubscriptionPricingInfo))
        expect(subject.size).to eq(155 * 200)
      end
    end
  end

  describe "parsing the first subscription pricing tier" do
    subject { pricing_tiers.first }

    it "correctly parses the pricing tier information" do
      expect(subject).to have_attributes(
        tier_stem:    "1",
        tier_name:    "ITC.addons.pricing.tier.1",
        pricing_info: be_an(Array)
      )
    end

    it "correctly parses the pricing info" do
      expect(subject.pricing_info.first).to have_attributes(
        country_code:       "IN",
        currency_symbol:    "R",
        wholesale_price:    6.09,
        wholesale_price2:   7.39,
        retail_price:       10,
        f_retail_price:     "Rs 10",
        f_wholesale_price:  "Rs 6.09",
        f_wholesale_price2: "Rs 7.39"
      )
    end
  end
end
