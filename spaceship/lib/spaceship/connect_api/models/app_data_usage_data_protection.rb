require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppDataUsageDataProtection
      include Spaceship::ConnectAPI::Model

      attr_accessor :deleted

      attr_mapping({
        "deleted" => "deleted"
      })

      # Found at https://appstoreconnect.apple.com/iris/v1/appDataUsageDataProtections
      module ID
        DATA_USED_TO_TRACK_YOU = "DATA_USED_TO_TRACK_YOU"
        DATA_LINKED_TO_YOU = "DATA_LINKED_TO_YOU"
        DATA_NOT_LINKED_TO_YOU = "DATA_NOT_LINKED_TO_YOU"

        DATA_NOT_COLLECTED = "DATA_NOT_COLLECTED"
      end

      def self.type
        return "appDataUsageDataProtections"
      end
    end
  end
end
