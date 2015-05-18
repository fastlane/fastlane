module Spaceship
  class App < Base

    attr_accessor :app_id, :name, :platform, :prefix, :bundle_id, :is_wildcard, :dev_push_enabled, :prod_push_enabled
    attr_mapping(
      'appIdId' => :app_id,
      'name' => :name,
      'appIdPlatform' => :platform,
      'prefix' => :prefix,
      'identifier' => :bundle_id,
      'isWildCard' => :is_wildcard,
      'isDevPushEnabled' => :dev_push_enabled,
      'isProdPushEnabled' => :prod_push_enabled
    )

    class << self
      def factory(attrs)
        self.new(attrs)
      end

      def all
        client.apps.map {|app| self.factory(app) }
      end

      # Creates a new App ID on the Apple Dev Portal
      # @param bundle_id [String] the bundle id of the app associated with this provisioning profile
      # @param name [String] the name of the App
      # if bundle_id ends with '*' then it is a wildcard id
      # otherwise, it is an explicit id
      def create!(bundle_id, name)
        if bundle_id.end_with?('*')
          type = :wildcard
        else
          type = :explicit
        end

        new_app = client.create_app!(type, name, bundle_id)
        self.new(new_app)
      end

      def find(bundle_id)
        all.find { |app|
          app.bundle_id == bundle_id
        }
      end
    end

    def delete!
      client.delete_app!(app_id)
      self
    end

    def details
      client.app(app_id)
    end
  end
end
