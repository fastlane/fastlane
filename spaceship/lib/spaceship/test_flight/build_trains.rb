module Spaceship::TestFlight
  class BuildTrains < Base
    ##
    # BuildTrains represent the collection of builds for a `train_version`
    #
    # Note: builds returned by BuildTrains are _partially_ complete. Properties
    # such as `exportCompliance`, `testInfo` and many others are not provided.
    # It is the responsibility of Build to lazy-load the necessary properties.
    #
    # See `Spaceship::TestFlight::Build#reload`

    def self.all(app_id: nil, platform: nil)
      data = client.get_build_trains(app_id: app_id, platform: platform)
      trains = {}
      data.each do |train_version|
        builds_data = client.get_builds_for_train(app_id: app_id, platform: platform, train_version: train_version)
        trains[train_version] = builds_data.map { |attrs| Build.new(attrs) }
      end

      self.new(trains)
    end

    def initialize(trains = {})
      @trains = trains
    end

    def get(key)
      @trains[key]
    end
    alias [] get

    def values
      @trains.values
    end
  end
end
