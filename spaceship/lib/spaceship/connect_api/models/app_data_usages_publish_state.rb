require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppDataUsagesPublishState
      include Spaceship::ConnectAPI::Model

      attr_accessor :published
      attr_accessor :last_published
      attr_accessor :last_published_by

      attr_mapping({
        "published" => "published",
        "lastPublished" => "last_published",
        "lastPublishedBy" => "last_published_by"
      })

      def self.type
        return "appDataUsagesPublishState"
      end

      #
      # API
      #

      def self.get(app_id: nil)
        resp = Spaceship::ConnectAPI.get_app_data_usages_publish_state(app_id: app_id)
        return resp.to_models.first
      end

      def publish!
        resp = Spaceship::ConnectAPI.patch_app_data_usages_publish_state(app_data_usages_publish_state_id: id, published: true)
        return resp.to_models.first
      end
    end
  end
end
