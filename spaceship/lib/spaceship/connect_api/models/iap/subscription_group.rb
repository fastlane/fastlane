require_relative '../../model'
module Spaceship
  class ConnectAPI
    class SubscriptionGroup
      include Spaceship::ConnectAPI::Model

      attr_accessor :reference_name

      attr_accessor :subscriptions,
                    :subscription_group_localizations

      attr_mapping({
        referenceName: 'reference_name',

        subscriptions: 'subscriptions'
      })

      ESSENTIAL_INCLUDES = [
        "subscriptions"
      ].join(",")

      def self.type
        return 'subscriptionGroups'
      end

      #
      # subscriptionGroupLocalizations
      #

      def get_subscription_group_localization(client: nil, localization_id:, includes: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_subscription_group_localization(localization_id: localization_id, includes: includes)
        return resps.to_models.first
      end

      def get_subscription_group_localizations(client: nil, includes: nil, limit: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_subscription_group_localizations(family_id: id, includes: includes, limit: limit).all_pages
        return resps.flat_map(&:to_models)
      end

      def create_subscription_group_localization(client: nil, custom_app_name:, locale:, name:)
        client ||= Spaceship::ConnectAPI
        resps = client.create_subscription_group_localization(custom_app_name: custom_app_name, locale: locale, name: name, family_id: id)
        return resps.flat_map(&:to_models).first
      end
    end
  end
end
