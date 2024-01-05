require_relative 'iap_subscription_pricing_info'

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
  end
end
