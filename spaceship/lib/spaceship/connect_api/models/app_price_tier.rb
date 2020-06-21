require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppPriceTier
      include Spaceship::ConnectAPI::Model

      def self.type
        return "appPriceTiers"
      end
    end
  end
end
