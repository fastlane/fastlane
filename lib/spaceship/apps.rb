module Spaceship
  class Apps
    include Enumerable
    extend Forwardable

    attr_reader :client
    def_delegators :@apps, :each, :first, :last

    class App < Struct.new(:app_id, :name, :platform, :prefix, :bundle_id, :is_wildcard, :dev_push_enabled, :prod_push_enabled)
    end

    #class Passbook < App; end
    #class WebsitePush < App; end
    #class ICloudContainer < App; end
    #class AppGroup < App; end
    #class Merchant < App; end

    def self.factory(response)
      values = response.values_at('appIdId', 'name', 'appIdPlatform', 'prefix', 'identifier', 'isWildCard', 'isDevPushEnabled', 'isProdPushEnabled')
      App.new(*values)
    end

    def initialize(client)
      @client = client
      @apps = client.apps.map {|app| self.class.factory(app) }
    end

    # Creates a new App ID on the Apple Dev Portal
    # @param bundle_id [String] the bundle id of the app associated with this provisioning profile
    # @param name [String] the name of the App
    # if bundle_id ends with '*' then it is a wildcard id
    # otherwise, it is an explicit id
    def create(bundle_id, name)
      if bundle_id.end_with?('*')
        type = :wildcard
      else
        type = :explicit
      end

      new_app = client.create_app(type, name, bundle_id)
      self.class.factory(new_app)
    end

    def delete(bundle_id)
      if app = find(bundle_id)
        client.delete_app(app.app_id)
        app
      end
    end

    def find(bundle_id)
      @apps.find do |app|
        app.bundle_id == bundle_id
      end
    end
    alias [] find

    def details(app_id)
      client.app(app_id)
    end
  end
end
