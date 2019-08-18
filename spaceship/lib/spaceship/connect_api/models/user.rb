require_relative '../model'
module Spaceship
  class ConnectAPI
    class User
      include Spaceship::ConnectAPI::Model

      attr_accessor :username
      attr_accessor :first_name
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
        "username" => "username",
        "firstName" => "first_name",
        "lastName" => "last_name",
        "email" => "email",
        "preferredCurrencyTerritory" => "preferred_currency_territory",
        "agreedToTerms" => "agreed_to_terms",
        "roles" => "roles",
        "allAppsVisible" => "all_apps_visible",
        "provisioningAllowed" => "provisioning_allowed",
        "emailVettingRequired" => "email_vetting_required",
        "notifications" => "notifications"
      })

      def self.type
        return "users"
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        return Spaceship::ConnectAPI.get_users(filter: filter, includes: includes)
      end

      def self.find(email: nil, includes: nil)
        return all(filter: { email: email }, includes: includes)
      end
    end
  end
end
