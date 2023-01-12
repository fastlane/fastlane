require_relative '../../model'
module Spaceship
  class ConnectAPI
    class Subscription
      include Spaceship::ConnectAPI::Model

      # Fields
      attr_accessor :available_in_all_territories,
                    :family_sharable,
                    :name,
                    :product_id,
                    :review_note,
                    :state,
                    :subscription_period,
                    :group_level

      # Relations
      attr_accessor :subscription_localizations

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
        groupLevel: 'group_level',
        subscriptionLocalizations: 'subscription_localizations'
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

      #
      # Subscription Localizations
      #

      def create_subscription_localization(client: nil, locale:, name:, description: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.create_subscription_localization(purchase_id: id, locale: locale, name: name, description: description)
        model = resps.to_models.first
        (self.subscription_localizations ||= []) << model
        model
      end

    end
  end
end
