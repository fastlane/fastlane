require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaTesterMetric
      include Spaceship::ConnectAPI::Model

      attr_accessor :install_count
      attr_accessor :crash_count
      attr_accessor :session_count
      attr_accessor :beta_tester_state
      attr_accessor :last_modified_date
      attr_accessor :installed_cf_bundle_short_version_string
      attr_accessor :installed_cf_bundle_version

      attr_mapping({
        "installCount" => "install_count",
        "crashCount" => "crash_count",
        "sessionCount" => "session_count",
        "betaTesterState" => "beta_tester_state",
        "lastModifiedDate" => "last_modified_date",
        "installedCfBundleShortVersionString" => "installed_cf_bundle_short_version_string",
        "installedCfBundleVersion" => "installed_cf_bundle_version"
      })

      module BetaTesterState
        INSTALLED = "INSTALLED"
        INVITED = "INVITED"
        NO_BUILDS = "NO_BUILDS"
      end

      def self.type
        return "betaTesterMetrics"
      end

      #
      # Helpers
      #

      def installed?
        return beta_tester_state == BetaTesterState::INSTALLED
      end
    end
  end
end
