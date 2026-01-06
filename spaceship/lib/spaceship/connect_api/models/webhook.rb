require_relative '../model'

module Spaceship
  class ConnectAPI
    class Webhook
      include Spaceship::ConnectAPI::Model

      attr_accessor :enabled
      attr_accessor :event_types
      attr_accessor :name
      attr_accessor :url

      attr_mapping({
        "enabled" => "enabled",
        "eventTypes" => "event_types",
        "name" => "name",
        "url" => "url"
      })

      # Found at https://developer.apple.com/documentation/appstoreconnectapi/webhookeventtype
      module EventType
        ALTERNATIVE_DISTRIBUTION_PACKAGE_AVAILABLE_UPDATED = "ALTERNATIVE_DISTRIBUTION_PACKAGE_AVAILABLE_UPDATED"
        ALTERNATIVE_DISTRIBUTION_PACKAGE_VERSION_CREATED = "ALTERNATIVE_DISTRIBUTION_PACKAGE_VERSION_CREATED"
        ALTERNATIVE_DISTRIBUTION_TERRITORY_AVAILABILITY_UPDATED = "ALTERNATIVE_DISTRIBUTION_TERRITORY_AVAILABILITY_UPDATED"
        APP_STORE_VERSION_APP_VERSION_STATE_UPDATED = "APP_STORE_VERSION_APP_VERSION_STATE_UPDATED"
        BACKGROUND_ASSET_VERSION_APP_STORE_RELEASE_STATE_UPDATED = "BACKGROUND_ASSET_VERSION_APP_STORE_RELEASE_STATE_UPDATED"
        BACKGROUND_ASSET_VERSION_EXTERNAL_BETA_RELEASE_STATE_UPDATED = "BACKGROUND_ASSET_VERSION_EXTERNAL_BETA_RELEASE_STATE_UPDATED"
        BACKGROUND_ASSET_VERSION_INTERNAL_BETA_RELEASE_CREATED = "BACKGROUND_ASSET_VERSION_INTERNAL_BETA_RELEASE_CREATED"
        BACKGROUND_ASSET_VERSION_STATE_UPDATED = "BACKGROUND_ASSET_VERSION_STATE_UPDATED"
        BETA_FEEDBACK_CRASH_SUBMISSION_CREATED = "BETA_FEEDBACK_CRASH_SUBMISSION_CREATED"
        BETA_FEEDBACK_SCREENSHOT_SUBMISSION_CREATED = "BETA_FEEDBACK_SCREENSHOT_SUBMISSION_CREATED"
        BUILD_BETA_DETAIL_EXTERNAL_BUILD_STATE_UPDATED = "BUILD_BETA_DETAIL_EXTERNAL_BUILD_STATE_UPDATED"
        BUILD_UPLOAD_STATE_UPDATED = "BUILD_UPLOAD_STATE_UPDATED"
      end

      def self.type
        return "webhooks"
      end

      #
      # API
      #

      def self.all(client: nil, app_id:, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_webhooks(app_id: app_id, filter: filter, includes: includes, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.create(client: nil, app_id:, enabled: true, event_types:, name:, secret:, url:)
        client ||= Spaceship::ConnectAPI
        resp = client.post_webhook(app_id: app_id, enabled: enabled, event_types: event_types, name: name, secret: secret, url: url)
        return resp.to_models.first
      end

      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        return client.delete_webhook(webhook_id: id)
      end
    end
  end
end
