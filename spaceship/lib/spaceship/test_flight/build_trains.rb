module TestFlight
  class BuildTrains < Base
    include Enumerable

    # This returns hashes that are partial versions of TestFlight::Build objects
    # We are using hashes here for now because we dont want
    # Them to be misinterpreted as Build objects.
    def self.all(provider_id: nil, app_id: nil, platform: nil)
      data = client.get_build_trains(provider_id: provider_id, app_id: app_id, platform: platform)
      trains = {}
      data.each do |train_version|
        trains[train_version] = client.get_builds_for_train(provider_id: provider_id, app_id: app_id, platform: platform, train_version: train_version)
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

    def each(&bock)
      @tains.each(&block)
    end

    def filter_trains(&block)
      values.flatten.select(&block)
    end
  end
end
