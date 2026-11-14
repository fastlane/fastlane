require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppPrice
      include Spaceship::ConnectAPI::Model

      attr_accessor :start_date
      attr_accessor :end_date
      attr_accessor :manual
      attr_accessor :app_price_point
      attr_accessor :territory

      attr_accessor :price_tier

      attr_mapping({
        "startDate" => "start_date",
        "endDate" => "end_date",
        "manual" => "manual",
        "appPricePoint" => "app_price_point",
        "territory" => "territory",

        "priceTier" => "price_tier"
      })

      def self.type
        return "appPrices"
      end
    end
  end
end
