module Spaceship
  # Represents an App ID from the Developer Portal
  class App < Base

    # @return (String) The identifier of this app, provided by the Dev Portal
    # @example RGAWZGXSAA
    attr_accessor :app_id

    # @return (String) The name you provided for this app
    attr_accessor :name

    # @return (String) the supported platform of this app
    # @example ios
    attr_accessor :platform

    # Prefix provided by the Dev Portal
    # @example 5A997XSHK2
    attr_accessor :prefix

    # @return (String) The bundle_id (app identifier) of your app
    # @example com.krausefx.app
    attr_accessor :bundle_id

    # @return (Bool) Is this app a wildcard app (e.g. com.krausefx.*)
    attr_accessor :is_wildcard

    # @return (Bool) Development Push Enabled?
    attr_accessor :dev_push_enabled

    # @return (Bool) Production Push Enabled?
    attr_accessor :prod_push_enabled

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
      # Create a new app from the server response. Is used internally
      def factory(attrs)
        self.new(attrs)
      end

      # @return (Array) Returns all apps available for this account
      def all
        client.apps.map { |app| self.factory(app) }
      end

      # Creates a new App ID on the Apple Dev Portal
      # 
      # if bundle_id ends with '*' then it is a wildcard id otherwise, it is an explicit id
      # @param bundle_id [String] the bundle id (app_identifier) of the app associated with this provisioning profile
      # @param name [String] the name of the App
      # @return (App) The app you just created
      def create!(bundle_id: bundle_id, name: name)
        if bundle_id.end_with?('*')
          type = :wildcard
        else
          type = :explicit
        end

        new_app = client.create_app!(type, name, bundle_id)
        self.new(new_app)
      end

      # Find a specific App ID based on the bundle_id
      # @return (App) The app you're looking for. This is nil if the app can't be found.
      def find(bundle_id)
        all.find do |app|
          app.bundle_id == bundle_id
        end
      end
    end

    # Delete this App ID. This action will most likely fail if the App ID is already in the store
    # or there are active profiles
    # @return (App) The app you just deletd
    def delete!
      client.delete_app!(app_id)
      self
    end
  end
end
