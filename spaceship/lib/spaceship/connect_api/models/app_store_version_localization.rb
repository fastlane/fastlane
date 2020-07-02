require_relative '../model'
require_relative './app_preview_set'
require_relative './app_screenshot_set'

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
        "description" =>  "description",
        "locale" =>  "locale",
        "keywords" =>  "keywords",
        "marketingUrl" =>  "marketing_url",
        "promotionalText" =>  "promotional_text",
        "supportUrl" =>  "support_url",
        "whatsNew" =>  "whats_new",

        "appScreenshotSets" =>  "app_screenshot_sets",
        "appPreviewSets" =>  "app_preview_sets"
      })

      def self.type
        return "appStoreVersionLocalizations"
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resp = Spaceship::ConnectAPI.get_app_store_version_localizations(filter: filter, includes: includes, limit: limit, sort: sort)
        return resp.to_models
      end

      def update(attributes: nil)
        Spaceship::ConnectAPI.patch_app_store_version_localization(app_store_version_localization_id: id, attributes: attributes)
      end

      def delete!(filter: {}, includes: nil, limit: nil, sort: nil)
        Spaceship::ConnectAPI.delete_app_store_version_localization(app_store_version_localization_id: id)
      end

      #
      # App Preview Sets
      #

      def get_app_preview_sets(filter: {}, includes: "appPreviews", limit: nil, sort: nil)
        filter ||= {}
        filter["appStoreVersionLocalization"] = id
        return Spaceship::ConnectAPI::AppPreviewSet.all(filter: filter, includes: includes, limit: limit, sort: sort)
      end

      def create_app_preview_set(attributes: nil)
        resp = Spaceship::ConnectAPI.post_app_preview_set(app_store_version_localization_id: id, attributes: attributes)
        return resp.to_models.first
      end

      #
      # App Screenshot Sets
      #

      def get_app_screenshot_sets(filter: {}, includes: "appScreenshots", limit: nil, sort: nil)
        filter ||= {}
        filter["appStoreVersionLocalization"] = id
        return Spaceship::ConnectAPI::AppScreenshotSet.all(filter: filter, includes: includes, limit: limit, sort: sort)
      end

      def create_app_screenshot_set(attributes: nil)
        resp = Spaceship::ConnectAPI.post_app_screenshot_set(app_store_version_localization_id: id, attributes: attributes)
        return resp.to_models.first
      end
    end
  end
end
