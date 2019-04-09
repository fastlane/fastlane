require_relative 'base'
require_relative 'build'

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

    def self.all(app_id: nil, platform: nil, retry_count: 3)
      client = Spaceship::ConnectAPI::Base.client

      builds = []
      included = []
      cursor = nil

      loop do
        builds_resp = client.get_builds(filter: { app: app_id, processingState: "VALID,PROCESSING,FAILED,INVALID" }, limit: 100, sort: "uploadedDate", includes: "preReleaseVersion,app", cursor: cursor, only_data: false)
        builds += builds_resp["data"]
        included += (builds_resp["included"] || [])

        next_page = builds_resp["links"]["next"]
        break if next_page.nil?

        uri = URI.parse(next_page)
        params = CGI.parse(uri.query)
        cursor = params["cursor"].first

        break if cursor.nil?
      end

      # Load with all of the data
      builds.map do |build|
        r = build["relationships"]["app"]["data"]
        build["app"] = included.find { |h| h["type"] == r["type"] && h["id"] == r["id"] }

        r = build["relationships"]["preReleaseVersion"]["data"]
        build["preReleaseVersion"] = included.find { |h| h["type"] == r["type"] && h["id"] == r["id"] }

        build
      end

      # Map to testflight build response????
      train_builds = builds.map do |build|
        h = {}

        h['buildVersion'] = build["attributes"]["version"]
        h['uploadDate'] = build["attributes"]["uploadedDate"]

        processing_state = build["attributes"]["processingState"]
        if processing_state == "VALID"
          h['externalState'] = Spaceship::TestFlight::Build::BUILD_STATES[:active]
        elsif processing_state == "PROCESSING"
          h['externalState'] = Spaceship::TestFlight::Build::BUILD_STATES[:processing]
        end

        h['appAdamId'] = build["app"]["id"]
        h['bundleId'] = build["app"]["attributes"]["bundleId"]

        h['trainVersion'] = build["preReleaseVersion"]["attributes"]["version"]

        h
      end

      trains = {}
      train_builds.each do |build|
        train_version = build["trainVersion"]
        trains[train_version] ||= []
        trains[train_version] << Spaceship::TestFlight::Build.new(build)
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

    def versions
      @trains.keys
    end
  end
end
