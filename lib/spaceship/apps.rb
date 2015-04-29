module Spaceship
  class Apps
    include Spaceship::SharedClient
    include Enumerable
    extend Forwardable

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

    def initialize
      @apps = client.apps.map {|app| self.class.factory(app) }
    end

    #if bundle_id ends with '*' then it is a wildcard id
    #otherwise, it is an explicit id
    def create(bundle_id, name)
      if bundle_id.end_with?('*')
        type = :wildcard
      else
        type = :explicit
      end

      new_app = client.create_app(type, name, bundle_id)
      self.class.factory(new_app)
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
