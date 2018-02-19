
module Spaceship
  module Tunes
    class IAPSubscriptionPricing < TunesBase
      # @return (String)
      attr_accessor :free_trials

      # @return ([Spaceship::Tunes::IAPSubscriptionPricingIntroOffer]) A list of all intro offers for the respective countries
      attr_accessor :intro_offers

      # @return ([Spaceship::Tunes::IAPSubscriptionPricingInfo]) A list of all prices for the respective countries
      attr_accessor :subscriptions

      def intro_offers
        @intro_offers ||= raw_data['introOffers'].map { |intro| IAPSubscriptionPricingIntroOffer.new(intro["value"]) }
      end

      def subscriptions
        @subscriptions ||= raw_data['subscriptions'].map { |info| IAPSubscriptionPricingInfo.new(info["value"]) }
      end

      def free_trials
        @free_trials ||= raw_data['freeTrials']
      end
    end
  end
end
