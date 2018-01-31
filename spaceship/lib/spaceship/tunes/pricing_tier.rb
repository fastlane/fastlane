require_relative 'pricing_info'

module Spaceship
  module Tunes
    class PricingTier < TunesBase
      # @return (String) Number of the price Tier (e.g. "0" for Tier 0 aka Free)
      attr_accessor :tier_stem

      # @return (String) Name of the tier (e.g. "Free" for Tier 0)
      attr_accessor :tier_name

      # @return (Array of Spaceship::Tunes::PricingInfo objects) A list of all prices for the respective countries
      attr_accessor :pricing_info

      attr_mapping(
        'tierStem' => :tier_stem,
        'tierName' => :tier_name
      )

      def pricing_info
        @pricing_info ||= raw_data['pricingInfo'].map { |info| PricingInfo.new(info) }
      end
    end
  end
end
