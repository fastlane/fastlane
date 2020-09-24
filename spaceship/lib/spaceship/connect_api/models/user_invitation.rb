require_relative '../model'
module Spaceship
  class ConnectAPI
    class UserInvitation
      include Spaceship::ConnectAPI::Model

      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :email
      attr_accessor :roles
      attr_accessor :all_apps_visible
      attr_accessor :provisioning_allowed

      attr_mapping({
        "firstName" => "first_name",
        "lastName" => "last_name",
        "email" => "email",
        "roles" => "roles",
        "allAppsVisible" => "all_apps_visible",
        "provisioningAllowed" => "provisioning_allowed"
      })

      def self.type
        return "userInvitations"
      end

      #
      # Managing invitations
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_users(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(email: nil, includes: nil)
        return all(filter: { email: email }, includes: includes)
      end
    end
  end
end
