require_relative '../../model'
module Spaceship
  class ConnectAPI
    class SubscriptionGroup
      include Spaceship::ConnectAPI::Model

      attr_accessor :reference_name

      attr_accessor :subscriptions

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
    end
  end
end