
module Spaceship
  module Tunes
    class IAPSubscriptionPricingIntroOffer < TunesBase
      # @return (String) country code, e.g. "US"
      attr_accessor :country

      # @return (String) duration, e.g. "2m"
      attr_accessor :duration_type

      # @return (Date) Start date, e.g. "2018-02-15"
      attr_accessor :start_date

      # @return (Date) End date, e.g. "2018-02-18" (nil allowed)
      attr_accessor :end_date

      # @return (Number) Number of periods, e.g. "1"
      attr_accessor :num_of_periods

      # @return (String) Number of the subscription price tier (e.g. "1" for Tier 1 )
      attr_accessor :tier_stem

      # @return (String) Offer mode type, e.g. "FreeTrial"
      attr_accessor :offer_mode_type

      attr_mapping(
        "country" => :country,
        "durationType" => :duration_type,
        "startDate" => :start_date,
        "endDate" => :end_date,
        "numOfPeriods" => :num_of_periods,
        "offerModeType" => :offer_mode_type,
        "tierStem" => :tier_stem,
      )
    end
  end
end
