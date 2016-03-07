module Spaceship
  module Portal
    # Represents an App ID from the Developer Portal
    class App < PortalBase
      # @return (String) The identifier of this app, provided by the Dev Portal
      # @example
      #   "RGAWZGXSAA"
      attr_accessor :app_id

      # @return (String) The name you provided for this app
      # @example
      #   "Spaceship"
      attr_accessor :name

      # @return (String) the supported platform of this app
      # @example
      #   "ios"
      attr_accessor :platform

      # Prefix provided by the Dev Portal
      # @example
      #   "5A997XSHK2"
      attr_accessor :prefix

      # @return (String) The bundle_id (app identifier) of your app
      # @example
      #   "com.krausefx.app"
      attr_accessor :bundle_id

      # @return (Bool) Is this app a wildcard app (e.g. com.krausefx.*)
      attr_accessor :is_wildcard

      # @return (Hash) Feature details
      attr_accessor :features

      # @return (Array) List of enabled features
      attr_accessor :enabled_features

      # @return (Bool) Development Push Enabled?
      attr_accessor :dev_push_enabled

      # @return (Bool) Production Push Enabled?
      attr_accessor :prod_push_enabled

      # @return (Fixnum) Number of associated app groups
      attr_accessor :app_groups_count

      # @return (Fixnum) Number of associated cloud containers
      attr_accessor :cloud_containers_count

      # @return (Fixnum) Number of associated identifiers
      attr_accessor :identifiers_count

      attr_mapping(
        'appIdId' => :app_id,
        'name' => :name,
        'appIdPlatform' => :platform,
        'prefix' => :prefix,
        'identifier' => :bundle_id,
        'isWildCard' => :is_wildcard,
        'features' => :features,
        'enabledFeatures' => :enabled_features,
        'isDevPushEnabled' => :dev_push_enabled,
        'isProdPushEnabled' => :prod_push_enabled,
        'associatedApplicationGroupsCount' => :app_groups_count,
        'associatedCloudContainersCount' => :cloud_containers_count,
        'associatedIdentifiersCount' => :identifiers_count
      )

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end

        # @param mac [Bool] Fetches Mac apps if true
        # @return (Array) Returns all apps available for this account
        def all(mac: false)
          client.apps(mac: mac).map { |app| self.factory(app) }
        end

        # Creates a new App ID on the Apple Dev Portal
        #
        # if bundle_id ends with '*' then it is a wildcard id otherwise, it is an explicit id
        # @param bundle_id [String] the bundle id (app_identifier) of the app associated with this provisioning profile
        # @param name [String] the name of the App
        # @param mac [Bool] is this a Mac app?
        # @return (App) The app you just created
        def create!(bundle_id: nil, name: nil, mac: false)
          if bundle_id.end_with?('*')
            type = :wildcard
          else
            type = :explicit
          end

          new_app = client.create_app!(type, name, bundle_id, mac: mac)
          self.new(new_app)
        end

        # Find a specific App ID based on the bundle_id
        # @param mac [Bool] Searches Mac apps if true
        # @return (App) The app you're looking for. This is nil if the app can't be found.
        def find(bundle_id, mac: false)
          all(mac: mac).find do |app|
            app.bundle_id == bundle_id
          end
        end
      end

      # Delete this App ID. This action will most likely fail if the App ID is already in the store
      # or there are active profiles
      # @return (App) The app you just deletd
      def delete!
        client.delete_app!(app_id, mac: mac?)
        self
      end

      # Fetch a specific App ID details based on the bundle_id
      # @return (App) The app you're looking for. This is nil if the app can't be found.
      def details
        app = client.details_for_app(self)
        self.class.factory(app)
      end

      # Associate specific groups with this app
      # @return (App) The updated detailed app. This is nil if the app couldn't be found
      def associate_groups(groups)
        raise "`associate_groups` not available for Mac apps" if mac?
        app = client.associate_groups_with_app(self, groups)
        self.class.factory(app)
      end

      # Update a service for the app with given AppService object
      # @return (App) The updated detailed app. This is nil if the app couldn't be found
      def update_service(service)
        raise "`update_service` not implemented for Mac apps" if mac?
        app = client.update_service_for_app(self, service)
        self.class.factory(app)
      end

      # @return (Bool) Is this a Mac app?
      def mac?
        platform == 'mac'
      end
    end
  end
end
