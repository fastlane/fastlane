require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppPrice
      include Spaceship::ConnectAPI::Model

      attr_accessor :start_date

      attr_accessor :price_tier

      attr_mapping({
        "startDate" => "start_date",

        "priceTier" => "price_tier"
      })

      def self.type
        return "appPrices"
      end
    end
  end
end
