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
      # An empty version string keeps the "#{version} (#{build})" format for partial data
      return Install.new(tester.installed_cf_bundle_short_version_string.to_s, tester.installed_cf_bundle_version)
    end

    private

    def install_from_app_devices(app_devices)
      installs = (app_devices || []).filter_map do |device|
        value = device["appBuildVersion"].to_s.strip
        next if value.empty?

        version, build = parse_build_version(value)
        Install.new(version || lookup_version(build, device["platform"]), build)
      end

      # A build number can restart with a new version, so the version is compared first
      return installs.max_by { |install| [sort_key(install.version), sort_key(install.build)] }
    end

    # @return [Array<String, nil>] the version (nil for a bare build number) and the build
    def parse_build_version(value)
      match = VERSION_AND_BUILD.match(value)
      return [match[1], match[2]] if match
      return [nil, value]
    end

    # Compared with Gem::Version, as app_store_build_number.rb:114 does.
    # A missing value (a version no build matched) or one Gem::Version rejects sorts lowest.
    def sort_key(value)
      return Gem::Version.new(value) if value && Gem::Version.correct?(value)
      return Gem::Version.new("0")
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
