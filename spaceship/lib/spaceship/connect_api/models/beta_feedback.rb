require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaFeedback
      include Spaceship::ConnectAPI::Model

      attr_accessor :timestamp
      attr_accessor :comment
      attr_accessor :email_address
      attr_accessor :device_model
      attr_accessor :os_version
      attr_accessor :bookmarked
      attr_accessor :locale
      attr_accessor :carrier
      attr_accessor :timezone
      attr_accessor :architecture
      attr_accessor :connection_status
      attr_accessor :paired_apple_watch
      attr_accessor :app_up_time_millis
      attr_accessor :available_disk_bytes
      attr_accessor :total_disk_bytes
      attr_accessor :network_type
      attr_accessor :battery_percentage
      attr_accessor :screen_width
      attr_accessor :screen_height

      attr_accessor :build
      attr_accessor :tester
      attr_accessor :screenshots

      attr_mapping({
        "timestamp" => "timestamp",
        "comment" => "comment",
        "emailAddress" => "email_address",
        "contactEmail" => "contact_email",
        "deviceModel" => "device_model",
        "osVersion" => "os_version",
        "bookmarked" => "bookmarked",
        "locale" => "locale",
        "carrier" => "carrier",
        "timezone" => "timezone",
        "architecture" => "architecture",
        "connectionStatus" => "connection_status",
        "pairedAppleWatch" => "paired_apple_watch",
        "appUpTimeMillis" => "app_up_time_millis",
        "availableDiskBytes" => "available_disk_bytes",
        "totalDiskBytes" => "total_disk_bytes",
        "networkType" => "network_type",
        "batteryPercentage" => "battery_percentage",
        "screenWidth" => "screen_width",
        "screenHeight" => "screen_height",

        "build" => "build",
        "tester" => "tester",
        "screenshots" => "screenshots"
      })

      def self.type
        return "betaFeedbacks"
      end

      #
      # API
      #

      def self.all(filter: {}, includes: "tester,build,screenshots", limit: nil, sort: nil)
        return Spaceship::ConnectAPI.get_beta_feedback(filter: filter, includes: includes, limit: limit, sort: sort)
      end
    end
  end
end
