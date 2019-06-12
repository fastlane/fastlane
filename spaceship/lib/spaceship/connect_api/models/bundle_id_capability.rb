require_relative '../model'
module Spaceship
  class ConnectAPI
    class BundleIdCapability
      include Spaceship::ConnectAPI::Model

      attr_accessor :identifier
      attr_accessor :bundleIdCapabilitiesSettingOption
      attr_accessor :last_name
      attr_accessor :email
      attr_accessor :preferred_currency_territory
      attr_accessor :agreed_to_terms
      attr_accessor :roles
      attr_accessor :all_apps_visible
      attr_accessor :provisioning_allowed
      attr_accessor :email_vetting_required
      attr_accessor :notifications

      attr_mapping({
        "identifier" => "username",
        "name" => "email",
        "seedId" => "last_name",
        "platform" => "agreed_to_terms"
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
