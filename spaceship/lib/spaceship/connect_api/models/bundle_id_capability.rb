require_relative '../model'
module Spaceship
  class ConnectAPI
    class BundleIdCapability
      include Spaceship::ConnectAPI::Model

      attr_accessor :capabilityType
      attr_accessor :bundleIdCapabilitiesSettingOption

      attr_mapping({
        "capabilityType" => "capabilityType",
        "settings" => "email"
      })

      module Platform
        IOS = "IOS"
        MAC_OS = "MAC_OS"
      end

      def self.type
        return "bundleIdCapabilities"
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
