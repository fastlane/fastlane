require_relative '../../model'
module Spaceship
  class ConnectAPI
    class SubscriptionIntroductoryOffer
      include Spaceship::ConnectAPI::Model

      attr_accessor :duration
      attr_accessor :end_date
      attr_accessor :number_of_periods
      attr_accessor :offer_mode
      attr_accessor :start_date

      attr_accessor :subscription_price_point
      attr_accessor :territory

      module Duration
        ONE_DAY = "ONE_DAY"
        THREE_DAYS = "THREE_DAYS"
        ONE_WEEK = "ONE_WEEK"
        TWO_WEEKS = "TWO_WEEKS"
        ONE_MONTH = "ONE_MONTH"
        TWO_MONTHS = "TWO_MONTHS"
        THREE_MONTHS = "THREE_MONTHS"
        SIX_MONTHS = "SIX_MONTHS"
        ONE_YEAR = "ONE_YEAR"
      end

      module OfferMode
        PAY_AS_YOU_GO = "PAY_AS_YOU_GO"
        PAY_UP_FRONT = "PAY_UP_FRONT"
        FREE_TRIAL = "FREE_TRIAL"
      end

      attr_mapping({
        duration: 'duration',
        endDate: 'end_date',
        numberOfPeriods: 'number_of_periods',
        offerMode: 'offer_mode',
        startDate: 'start_date',

        subscriptionPricePoint: 'subscription_price_point',
        territory: 'territory'
      })

      ESSENTIAL_INCLUDES = [
        "subscriptionPricePoint",
        "territory"
      ].join(",")

      def self.type
        return 'subscriptionIntroductoryOffers'
      end
    end
  end
end