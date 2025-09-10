require_relative '../model'
require_relative './app_screenshot_set'

module Spaceship
  class ConnectAPI
    class AppCustomProductPageLocalization
      include Spaceship::ConnectAPI::Model

      attr_accessor :locale
      attr_accessor :app_screenshot_sets

      attr_mapping({
        "locale" => "locale",
        "appScreenshotSets" => "app_screenshot_sets"
      })

      def self.type
        return "appCustomProductPageLocalizations"
      end

      # API
      def self.get(client: nil, app_custom_product_page_localization_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_custom_product_page_localization(app_custom_product_page_localization_id: app_custom_product_page_localization_id, filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end

      def get_app_screenshot_sets(client: nil, filter: {}, includes: "appScreenshots", limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        return client.get_app_custom_product_page_localization_app_screenshot_sets(app_custom_product_page_localization_id: id, filter: filter, includes: includes, limit: limit, sort: sort).to_models
      end

      def create_app_screenshot_set(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_app_custom_product_page_localization_app_screenshot_set(app_custom_product_page_localization_id: id, attributes: attributes)
        return resp.to_models.first
      end
    end
  end
end
