require_relative '../model'

module Spaceship
  class ConnectAPI
    class AppCustomProductPageVersion
      include Spaceship::ConnectAPI::Model

      attr_accessor :state

      attr_mapping({
        "state" => "state"
      })

      def self.type
        return "appCustomProductPageVersions"
      end

      # API
      def self.all(client: nil, app_custom_product_page_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_custom_product_page_versions(app_custom_product_page_id: app_custom_product_page_id, filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end

      def self.get(client: nil, app_custom_product_page_version_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_custom_product_page_version(app_custom_product_page_version_id: app_custom_product_page_version_id, filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end

      def get_localizations(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_custom_product_page_version_localizations(app_custom_product_page_version_id: id, filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end

      def create_localization(client: nil, attributes: {})
        client ||= Spaceship::ConnectAPI
        resp = client.post_app_custom_product_page_version_localization(app_custom_product_page_version_id: id, attributes: attributes)
        return resp.to_models.first
      end
    end
  end
end
