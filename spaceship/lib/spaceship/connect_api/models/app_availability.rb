require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppAvailability
      include Spaceship::ConnectAPI::Model

      attr_accessor :app
      attr_accessor :available_in_new_territories

      attr_accessor :territoryAvailabilities

      attr_mapping({
          app: 'app',
          availableInNewTerritories: 'available_in_new_territories',
          territoryAvailabilities: 'territory_availabilities'
      })

      def self.type
        return 'appAvailabilities'
      end
    end
  end
end
