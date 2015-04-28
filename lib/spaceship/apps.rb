module Spaceship
  class Apps
    include Spaceship::SharedClient
    include Enumerable
    extend Forwardable

    def_delegators :@apps, :each, :first, :last

    App = Struct.new(:app_id, :name, :platform, :prefix, :identifier, :is_wildcard, :dev_push_enabled, :prod_push_enabled)

    def initialize
      @apps = client.apps.map do |app|
        values = app.values_at('appIdId', 'name', 'appIdPlatform', 'prefix', 'identifier', 'isWildCard', 'isDevPushEnabled', 'isProdPushEnabled')
        App.new(*values)
      end
    end

    def find(identifier)
      @apps.find do |app|
        app.identifier == identifier
      end
    end
    alias [] find

    def details(app_id)
      client.app(app_id)
    end


    # Example
    # app_id="572XTN75U2",
    # name="App Name",
    # platform="ios",
    # prefix="5A997XSHK2",
    # identifier="net.sunapps.7",
    # is_wildcard=false,
    # dev_push_enabled=false,
    # prod_push_enabled=false>,
  end
end
