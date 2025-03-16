require_relative '../../model'
module Spaceship
  class ConnectAPI
    class InAppPurchaseAvailability
      include Spaceship::ConnectAPI::Model

      attr_accessor :available_in_new_territories

      attr_accessor :available_territories
      attr_accessor :in_app_purchase

      attr_mapping({
        available_in_new_territories: 'availableInNewTerritories',

        available_territories: 'availableTerritories',
        in_app_purchase: 'in_app_purchase'
      })

      ESSENTIAL_INCLUDES = [
        "availableTerritories",
      ].join(",")

      def self.type
        return 'inAppPurchaseAvailabilities'
      end
    end
  end
end
