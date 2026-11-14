require_relative '../model'
require_relative '../../errors'
module Spaceship
  class ConnectAPI
    class AppPriceSchedule
      include Spaceship::ConnectAPI::Model

      attr_accessor :app
      attr_accessor :base_territory
      attr_accessor :manual_prices

      attr_mapping({
        "app" => "app",
        "baseTerritory" => "base_territory",
        "manualPrices" => "manual_prices"
      })

      def self.type
        return "appPriceSchedules"
      end

      def self.create(client: nil, app_id:, base_territory_id:, manual_prices:)
        client ||= Spaceship::ConnectAPI
        return client.post_app_price_schedule(app_id: app_id, base_territory_id: base_territory_id, manual_prices: manual_prices).to_models.first
      end

      def get_manual_prices(client: nil, filter: {}, includes: "appPricePoint,territory", limit: 200)
        client ||= Spaceship::ConnectAPI
        begin
          response = client.get_app_price_schedule_manual_prices(app_price_schedule_id: id, filter: filter, includes: includes, limit: limit)
        rescue Spaceship::UnexpectedResponse => error
          # Apple returns a synthetic schedule for an app that has never had a
          # price, but its manualPrices request reports this missing null resource.
          # Do not hide other errors, or errors while reading subsequent pages.
          missing_price = "The specified resource does not exist - There is no resource of type 'null' with id '#{id}'"
          return [] if [missing_price, "#{missing_price}."].include?(error.message)
          raise
        end
        return response.all_pages.flat_map(&:to_models)
      end
    end
  end
end
