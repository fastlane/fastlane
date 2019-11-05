require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaBuildMetric
      include Spaceship::ConnectAPI::Model

      attr_accessor :install_count
      attr_accessor :crash_count
      attr_accessor :invite_count
      attr_accessor :seven_day_tester_count

      attr_mapping({
        "installCount" => "install_count",
        "crashCount" => "crash_count",
        "inviteCount" => "invite_count",
        "sevenDayTesterCount" => "seven_day_tester_count"
      })

      def self.type
        return "betaBuildMetrics"
      end
    end
  end
end
