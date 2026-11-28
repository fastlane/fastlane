require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppDataUsageGrouping
      include Spaceship::ConnectAPI::Model

      attr_accessor :deleted

      attr_mapping({
        "deleted" => "deleted"
      })

      def self.type
        return "appDataUsageGroupings"
      end
    end
  end
end
