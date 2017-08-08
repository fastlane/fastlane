module Spaceship
  module Tunes
    class IAPSubscriptionPricingTier < TunesBase
      # @return (String) Number of the subscription price tier (e.g. "1" for Tier 1 )
      attr_accessor :tier_stem

      # @return (String) Name of the tier (e.g. "ITC.addons.pricing.tier.1" for Tier 1)
      attr_accessor :tier_name

      # @return ([Spaceship::Tunes::IAPSubscriptionPricingInfo]) A list of all prices for the respective countries
      attr_accessor :pricing_info

      attr_mapping(
        "tierStem" => :tier_stem,
        "tierName" => :tier_name
      )

      def pricing_info
        @pricing_info ||= raw_data['pricingInfo'].map { |info| IAPSubscriptionPricingInfo.new(info) }
      end
    end

    class IAPSubscriptionPricingInfo < TunesBase
      # @return (String) country code, e.g. "US"
      attr_accessor :country_code

      # @return (String) currency symbol, e.g. "$"
      attr_accessor :currency_symbol

      # @return (String) currency code, e.g. "USD"
      attr_accessor :currency_code

      # @return (Number) net proceedings for the developer in the first year
      attr_accessor :wholesale_price

      # @return (Number) net proceedings for the developer after the first year
      attr_accessor :wholesale_price2

      # @return (Number) customer price
      attr_accessor :retail_price

      # @return (String) formatted customer price, e.g. "$0.00"
      attr_accessor :f_retail_price

      # @return (String) formatted net proceedings in the first year, e.g. "$0.00"
      attr_accessor :f_wholesale_price

      # @return (String) formatted net proceedings after the first year, e.g. "$0.00"
      attr_accessor :f_wholesale_price2

      attr_mapping(
        "countryCode" => :country_code,
        "currencySymbol" => :currency_symbol,
        "currencyCode" => :currency_code,
        "wholesalePrice" => :wholesale_price,
        "wholesalePrice2" => :wholesale_price2,
        "retailPrice" => :retail_price,
        "fRetailPrice" => :f_retail_price,
        "fWholesalePrice" => :f_wholesale_price,
        "fWholesalePrice2" => :f_wholesale_price2
      )
    end
  end
end
