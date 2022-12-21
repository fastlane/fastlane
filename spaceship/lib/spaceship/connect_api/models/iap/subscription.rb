require_relative '../../model'
module Spaceship
  class ConnectAPI
    class Subscription
      include Spaceship::ConnectAPI::Model

      attr_accessor :available_in_all_territories
      attr_accessor :family_sharable
      attr_accessor :name
      attr_accessor :product_id
      attr_accessor :review_note
      attr_accessor :state
      attr_accessor :subscription_period
      attr_accessor :group_level

      module Period
        ONE_WEEK = "ONE_WEEK"
        ONE_MONTH = "ONE_MONTH"
        TWO_MONTHS = "TWO_MONTHS"
        THREE_MONTHS = "THREE_MONTHS"
        SIX_MONTHS = "SIX_MONTHS"
        ONE_YEAR = "ONE_YEAR"
      end

      module State
        APPROVED = "APPROVED"
        DEVELOPER_ACTION_NEEDED = "DEVELOPER_ACTION_NEEDED"
        DEVELOPER_REMOVED_FROM_SALE = "DEVELOPER_REMOVED_FROM_SALE"
        IN_REVIEW = "IN_REVIEW"
        MISSING_METADATA = "MISSING_METADATA"
        PENDING_BINARY_APPROVAL = "PENDING_BINARY_APPROVAL"
        READY_TO_SUBMIT = "READY_TO_SUBMIT"
        REJECTED = "REJECTED"
        REMOVED_FROM_SALE = "REMOVED_FROM_SALE"
        WAITING_FOR_REVIEW = "WAITING_FOR_REVIEW"
      end

      attr_mapping({
        availableInAllTerritories: 'available_in_all_territories',
        familySharable: 'family_sharable',
        name: 'name',
        productId: 'product_id',
        reviewNote: 'review_note',
        state: 'state',
        subscriptionPeriod: 'subscription_period',
        groupLevel: 'group_level'
      })

      def self.type
        return 'subscriptions'
      end

      #
      # Introductory Offers
      #

      def get_introductory_offers(client: nil, filter: {}, includes: Spaceship::ConnectAPI::SubscriptionIntroductoryOffer::ESSENTIAL_INCLUDES, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_subscription_introductory_offers(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      #
      # Prices
      #

      def get_prices(client: nil, filter: {}, includes: Spaceship::ConnectAPI::SubscriptionPrice::ESSENTIAL_INCLUDES, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_subscription_prices(app_id: id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

    end
  end
end