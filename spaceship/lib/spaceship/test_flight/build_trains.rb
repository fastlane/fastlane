module TestFlight
  class BuildTrains

    include Enumerable

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
    alias_method :[], :get

    def values
      @trains.values
    end

    def each(&bock)
      @tains.each(&block)
    end
  end
end