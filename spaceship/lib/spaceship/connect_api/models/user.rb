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

      attr_accessor :visible_apps

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
        "notifications" => "notifications",

        "visibleApps" => "visible_apps"
      })

      ESSENTIAL_INCLUDES = [
        "visibleApps"
      ].join(",")

      def self.type
        return "users"
      end

      #
      # API
      #

      def self.all(client: nil, filter: {}, includes: ESSENTIAL_INCLUDES, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_users(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(client: nil, email: nil, includes: ESSENTIAL_INCLUDES)
        client ||= Spaceship::ConnectAPI
        return all(client: client, filter: { email: email }, includes: includes)
      end

      def get_visible_apps(client: nil, limit: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_user_visible_apps(user_id: id, limit: limit)
        return resp.to_models
      end
    end
  end
end
