module Spaceship
  module Portal
    # Represents an App ID from the Developer Portal
    class App < PortalBase
      # @return (String) The identifier of this app, provided by the Dev Portal
      # @example
      #   "RGAWZGXSAA"
      attr_accessor :app_id

      # @return (String) The identifier of this web app, provided by the Dev Portal
      attr_accessor :website_push_id

      # @return (String) The identifier of this pass app, provided by the Dev Portal
      attr_accessor :pass_type_id

      # @return (String) The identifier of this merchant app, provided by the Dev Portal
      attr_accessor :omc_id

      # @return (String) The identifier of this iCloud app, provided by the Dev Portal
      attr_accessor :cloud_container

      # @return (String) The name you provided for this app
      # @example
      #   "Spaceship"
      attr_accessor :name

      # @return (String) the supported platform of this app
      # @example
      #   "ios"
      #   "mac"
      #   "tvOS"
      #   "web"
      #   "pass"
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
        'websitePushId' => :website_push_id,
        'cloudContainer' => :cloud_container,
        'omcId' => :omc_id,
        'passTypeId' => :pass_type_id,
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

      # Represents an iOS platform in Spaceship
      IOS = 'ios'.freeze

      # Represents a Web platform in Spaceship
      WEB = 'web'.freeze

      # Represents a Pass platform in Spaceship
      PASS = 'pass'.freeze

      # Represents a tvOS platform in Spaceship
      TVOS = 'tvOS'.freeze

      # Represents a Mac platform in Spaceship
      MAC = 'mac'.freeze

      # Represents a Merchant platform in Spaceship
      MERCHANT = 'merchant'.freeze

      # Represents an iCloud Container platform in Spaceship
      ICLOUD = 'icloud'.freeze

      # An array representing app platforms that need the platform added.
      ADD_PLATFORM = [
        PASS,
        ICLOUD,
        MERCHANT,
        WEB
      ].freeze

      PLATFORMS = [
        IOS,
        WEB,
        TVOS,
        MAC,
        PASS,
        ICLOUD,
        MERCHANT
      ].freeze

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end

        # <b>DEPRECATED:</b> Use <tt>all_by_platform</tt> instead.
        # @param mac [Bool] Fetches Mac apps if true
        # @return (Array) Returns all apps available for this account
        def all(mac: false)
          puts '`all` is deprecated. Please use `all_by_platform` instead.'.red
          all_by_platform(platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
        end

        # @param platform (String) The platform to search for
        # @return (Array) Returns all apps available for this account
        def all_by_platform(platform: nil)
          client.apps_by_platform(platform: platform).map { |app| self.factory(app) }
        end

        # <b>DEPRECATED:</b> Use <tt>create_by_platform!</tt> instead.
        # Creates a new App ID on the Apple Dev Portal
        #
        # if bundle_id ends with '*' then it is a wildcard id otherwise, it is an explicit id
        # @param bundle_id [String] the bundle id (app_identifier) of the app associated with this provisioning profile
        # @param name [String] the name of the App
        # @param mac [Bool] is this a Mac app?
        # @return (App) The app you just created
        def create!(bundle_id: nil, name: nil, mac: false)
          puts '`create!` is deprecated. Please use `create_by_platform!` instead.'.red
          create_by_platform!(bundle_id: bundle_id, name: name, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
        end

        # Creates a new App ID on the Apple Dev Portal
        #
        # if bundle_id ends with '*' then it is a wildcard id otherwise, it is an explicit id
        # @param bundle_id [String] the bundle id (app_identifier) of the app associated with this provisioning profile
        # @param name [String] the name of the App
        # @param platform [String] The platform
        # @return (App) The app you just created
        def create_by_platform!(bundle_id: nil, name: nil, platform: Spaceship::Portal::App::IOS)
          if bundle_id.end_with?('*')
            type = :wildcard
          else
            type = :explicit
          end

          new_app = client.create_app_by_platform!(type, name, bundle_id, platform: platform)
          self.new(new_app)
        end

        # <b>DEPRECATED:</b> Use <tt>find_by_platform</tt> instead.
        # Find a specific App ID based on the bundle_id
        # @param mac [Bool] Searches Mac apps if true
        # @return (App) The app you're looking for. This is nil if the app can't be found.
        def find(bundle_id, mac: false)
          puts '`find` is deprecated. Please use `find_by_platform` instead.'.red
          find_by_platform(bundle_id, platform: mac ? Spaceship::Portal::App::MAC : Spaceship::Portal::App::IOS)
        end

        # Find a specific App ID based on the bundle_id
        # @param platform [String] The platform to search for
        # @return (App) The app you're looking for. This is nil if the app can't be found.
        def find_by_platform(bundle_id, platform: nil)
          all_by_platform(platform: platform).detect do |app|
            app.bundle_id == bundle_id
          end
        end
      end

      # Delete this App ID. This action will most likely fail if the App ID is already in the store
      # or there are active profiles
      # @return (App) The app you just deleted
      def delete!
        client.delete_app_by_platform!(app_id, platform: platform)
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
        raise "`associate_groups` not available for Web apps" if web?
        app = client.associate_groups_with_app(self, groups)
        self.class.factory(app)
      end

      # Update a service for the app with given AppService object
      # @return (App) The updated detailed app. This is nil if the app couldn't be found
      def update_service(service)
        raise "`update_service` not implemented for Mac apps" if mac?
        raise "`update_service` not implemented for Web apps" if web?
        app = client.update_service_for_app(self, service)
        self.class.factory(app)
      end

      # @return (Bool) Is this a Mac app?
      def mac?
        platform == Spaceship::Portal::App::MAC
      end

      # @return (Bool) Is this a Web app?
      def web?
        platform == Spaceship::Portal::App::WEB
      end
    end
  end
end
