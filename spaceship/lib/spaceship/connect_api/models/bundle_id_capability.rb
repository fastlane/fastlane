require_relative '../model'
module Spaceship
  class ConnectAPI
    class BundleIdCapability
      include Spaceship::ConnectAPI::Model

      attr_accessor :capability_type
      attr_accessor :settings

      attr_mapping({
        "capabilityType" => "capability_type",
        "settings" => "settings"
      })

      module Type
        ICLOUD = "ICLOUD"
        IN_APP_PURCHASE = "IN_APP_PURCHASE"
        GAME_CENTER = "GAME_CENTER"
        PUSH_NOTIFICATIONS = "PUSH_NOTIFICATIONS"
        WALLET = "WALLET"
        INTER_APP_AUDIO = "INTER_APP_AUDIO"
        MAPS = "MAPS"
        ASSOCIATED_DOMAINS = "ASSOCIATED_DOMAINS"
        PERSONAL_VPN = "PERSONAL_VPN"
        APP_GROUPS = "APP_GROUPS"
        HEALTHKIT = "HEALTHKIT"
        HOMEKIT = "HOMEKIT"
        WIRELESS_ACCESSORY_CONFIGURATION = "WIRELESS_ACCESSORY_CONFIGURATION"
        APPLE_PAY = "APPLE_PAY"
        DATA_PROTECTION = "DATA_PROTECTION"
        SIRIKIT = "SIRIKIT"
        NETWORK_EXTENSIONS = "NETWORK_EXTENSIONS"
        MULTIPATH = "MULTIPATH"
        HOT_SPOT = "HOT_SPOT"
        NFC_TAG_READING = "NFC_TAG_READING"
        CLASSKIT = "CLASSKIT"
        AUTOFILL_CREDENTIAL_PROVIDER = "AUTOFILL_CREDENTIAL_PROVIDER"
        ACCESS_WIFI_INFORMATION = "ACCESS_WIFI_INFORMATION"

        # Undocumented as of 2020-06-09
        MARZIPAN = "MARZIPAN" # Catalyst
      end

      def self.type
        return "bundleIdCapabilities"
      end

      #
      # Helpers
      #

      def is_type?(type)
        # JWT session returns type under "capability_type" attribute
        # Web session returns type under "id" attribute but with "P7GJR49W72_" prefixed
        return capability_type == type || id.end_with?(type)
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        return users_client.get_users(filter: filter, includes: includes)
      end

      def self.find(email: nil, includes: nil)
        return all(filter: { email: email }, includes: includes)
      end
    end
  end
end
