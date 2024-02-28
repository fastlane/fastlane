require_relative '../model'
module Spaceship
  class ConnectAPI
    class TerritoryAvailability
      include Spaceship::ConnectAPI::Model

      attr_accessor :available
      attr_accessor :content_statuses
      attr_accessor :pre_order_enabled
      attr_accessor :pre_order_publish_date
      attr_accessor :release_date

      attr_mapping({
        available: 'available',
        contentStatuses: 'content_statuses',
        preOrderEnabled: 'pre_order_enabled',
        preOrderPublishDate: 'pre_order_publish_date',
        releaseDate: 'release_date'
      })

      def self.type
        return 'territoryAvailabilities'
      end
    end
  end
end
