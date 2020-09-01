require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppPricePoint
      include Spaceship::ConnectAPI::Model

      attr_accessor :customer_price

      attr_accessor :proceeds

      attr_accessor :price_tier
      attr_accessor :territory

      attr_mapping({
        "customerPrice" => "customer_price",
        "proceeds" => "proceeds",
        "priceTier" => "price_tier",
        "territory" => "territory"
      })

      def self.type
        return "appPricePoints"
      end
    end
  end
end
