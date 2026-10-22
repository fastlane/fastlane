require 'spaceship'

require_relative 'module'

module Pilot
  # Works out the version and build a tester has installed from the beta tester record
  class TesterInstallInfo
    Install = Struct.new(:version, :build) do
      def display_version
        return "#{version} (#{build})" if version
        return build
      end
    end

    # Matches an appBuildVersion of the form "1.2.3 (1234)"
    VERSION_AND_BUILD = /\A(.+) \(([^()]+)\)\z/

    # @param app [#id, nil] the app used to look up the version of a bare build number
    def initialize(app: nil)
      @app = app
      @versions_by_build = {}
    end

    # @return [Install, nil] nil when the tester has not installed the app or has no install data
    def install_for(tester)
      if tester.state
        return nil unless tester.state == Spaceship::ConnectAPI::BetaTester::State::INSTALLED
        return install_from_app_devices(tester.app_devices)
      end

      return nil unless tester.beta_tester_state == Spaceship::ConnectAPI::BetaTesterMetric::BetaTesterState::INSTALLED
      return Install.new(tester.installed_cf_bundle_short_version_string, tester.installed_cf_bundle_version)
    end

    private

    def install_from_app_devices(app_devices)
      candidates = (app_devices || []).select { |device| device["appBuildVersion"] }.map do |device|
        version, build = parse_build_version(device["appBuildVersion"])
        { version: version, build: build, platform: device["platform"] }
      end

      latest = candidates.max_by { |candidate| build_sort_key(candidate[:build]) }
      return nil if latest.nil?

      version = latest[:version] || lookup_version(latest[:build], latest[:platform])
      return Install.new(version, latest[:build])
    end

    # @return [Array<String, nil>] the version (nil for a bare build number) and the build
    def parse_build_version(value)
      match = VERSION_AND_BUILD.match(value)
      return [match[1], match[2]] if match
      return [nil, value]
    end

    # Builds that are not valid versions sort lowest, as in app_store_build_number
    def build_sort_key(build)
      return Gem::Version.correct?(build) ? Gem::Version.new(build) : Gem::Version.new("0")
    end

    def lookup_version(build, platform)
      return nil if @app.nil?

      platform = nil unless Spaceship::ConnectAPI::Platform::ALL.include?(platform)
      key = [build, platform]
      unless @versions_by_build.key?(key)
        builds = Spaceship::ConnectAPI::Build.all(app_id: @app.id, build_number: build, platform: platform)
        @versions_by_build[key] = builds.first&.app_version
      end
      return @versions_by_build[key]
    end
  end
end
