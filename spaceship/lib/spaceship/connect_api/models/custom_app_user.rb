require_relative '../model'
module Spaceship
  class ConnectAPI
    class CustomAppUser
      include Spaceship::ConnectAPI::Model

      attr_accessor :apple_id

      attr_mapping({
        "appleId" => "apple_id"
      })

      def self.type
        return "customAppUsers"
      end

      #
      # API
      #

      def self.all(app_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_custom_app_users(
          app_id: app_id,
          filter: filter,
          includes: includes,
          limit: nil,
          sort: nil
        ).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.create(app_id: nil, apple_id: nil)
        return Spaceship::ConnectAPI.post_custom_app_user(app_id: app_id, apple_id: apple_id).first
      end

      def delete!
        Spaceship::ConnectAPI.delete_custom_app_user(custom_app_user_id: id)
      end
    end
  end
end
