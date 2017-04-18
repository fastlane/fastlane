module TestFlight
  class BuildTrains

    include Enumerable

    def initialize(provider_id: nil, app_id: nil, platform: nil)
      @data = client.get_build_trains(provider_id: provider_id, app_id: app_id, platform: platform)
      @trains = {}
      @data.each do |train_version|
        @trains[train_version] = Build.all_builds_for_train(provider_id: provider_id, app_id: app_id, platform: platformm train_version: train_version)
      end
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

    def builds
      builds = client.get_builds_for_train(provider_id: nil, app_id: nil, platform: nil, train_version: self.version)
    end
  end
end