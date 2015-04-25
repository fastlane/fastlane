
module Spaceship
  class App
    include Spaceship::SharedClient

    attr_accessor :app_id, :name, :platform, :prefix, :identifier, :is_wildcard

    def self.all
      Spaceship::Client.instance.apps.map do |device|
        App.new(
          app_id: device['appIdId'],
          name: device['name'],
          platform: device['appIdPlatform'],
          prefix: device['prefix'],
          identifier: device['identifier'],
          is_wildcard: device['isWildCard']
        )
      end
    end

    def initialize(attrs = {})
      attrs.each do |attr, value|
        send("#{attr}=", value)
      end
    end

    def to_s
      [self.name, self.identifier].join(" - ")
    end

    #this should probably be in the model.
    def app(bundle_id)
      apps.select do |app|
        app['appIdId'] == bundle_id
      end.first
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
