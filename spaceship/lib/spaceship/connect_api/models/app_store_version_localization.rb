require_relative '../model'
require_relative './app_preview_set'
require_relative './app_screenshot_set'
require_relative '../../errors'

module Spaceship
  class ConnectAPI
    class AppStoreVersionLocalization
      include Spaceship::ConnectAPI::Model

      attr_accessor :description
      attr_accessor :locale
      attr_accessor :keywords
      attr_accessor :marketing_url
      attr_accessor :promotional_text
      attr_accessor :support_url
      attr_accessor :whats_new

      attr_accessor :app_screenshot_sets
      attr_accessor :app_preview_sets

      attr_mapping({
        "description" => "description",
        "locale" => "locale",
        "keywords" => "keywords",
        "marketingUrl" => "marketing_url",
        "promotionalText" => "promotional_text",
        "supportUrl" => "support_url",
        "whatsNew" => "whats_new",

        "appScreenshotSets" => "app_screenshot_sets",
        "appPreviewSets" => "app_preview_sets"
      })

      def self.type
        return "appStoreVersionLocalizations"
      end

      #
      # API
      #

      def self.get(client: nil, app_store_version_localization_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_store_version_localization(app_store_version_localization_id: app_store_version_localization_id, filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      rescue => error
        raise Spaceship::AppStoreLocalizationError.new(@locale, error)
      end

      def self.all(client: nil, app_store_version_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_store_version_localizations(app_store_version_id: app_store_version_id, filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      rescue => error
        raise Spaceship::AppStoreLocalizationError.new(@locale, error)
      end

      def update(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        attributes = reverse_attr_mapping(attributes)
        client.patch_app_store_version_localization(app_store_version_localization_id: id, attributes: attributes)
      rescue => error
        raise Spaceship::AppStoreLocalizationError.new(@locale, error)
      end

      def delete!(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_app_store_version_localization(app_store_version_localization_id: id)
      rescue => error
        raise Spaceship::AppStoreLocalizationError.new(@locale, error)
      end

      #
      # App Preview Sets
      #

      def get_app_preview_sets(client: nil, filter: {}, includes: "appPreviews", limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        filter ||= {}
        filter["appStoreVersionLocalization"] = id
        return Spaceship::ConnectAPI::AppPreviewSet.all(client: client, filter: filter, includes: includes, limit: limit, sort: sort)
      rescue => error
        raise Spaceship::AppStoreAppPreviewError.new(@locale, error)
      end

      def create_app_preview_set(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_app_preview_set(app_store_version_localization_id: id, attributes: attributes)
        return resp.to_models.first
      rescue => error
        raise Spaceship::AppStoreAppPreviewError.new(@locale, error)
      end

      #
      # App Screenshot Sets
      #

      def get_app_screenshot_sets(client: nil, filter: {}, includes: "appScreenshots", limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        return Spaceship::ConnectAPI::AppScreenshotSet.all(client: client, app_store_version_localization_id: id, filter: filter, includes: includes, limit: limit, sort: sort)
      rescue => error
        raise Spaceship::AppStoreScreenshotError.new(@locale, error)
      end

      def create_app_screenshot_set(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_app_screenshot_set(app_store_version_localization_id: id, attributes: attributes)
        return resp.to_models.first
      rescue => error
        raise Spaceship::AppStoreScreenshotError.new(@locale, error)
      end
    end
  end
end
