require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppCategory
      include Spaceship::ConnectAPI::Model

      attr_accessor :platforms

      attr_mapping({
        "platforms" => "platforms"
      })

      def self.type
        return "appCategories"
      end
    end
  end
end
