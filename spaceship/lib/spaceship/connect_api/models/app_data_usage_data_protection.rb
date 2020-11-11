require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppDataUsageDataProtection
      include Spaceship::ConnectAPI::Model

      attr_accessor :deleted

      attr_mapping({
        "deleted" => "deleted"

      })

      def self.type
        return "appDataUsageDataProtections"
      end
    end
  end
end
