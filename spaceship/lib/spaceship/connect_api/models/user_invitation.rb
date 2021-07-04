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

      attr_accessor :visible_apps

      attr_mapping({
        "firstName" => "first_name",
        "lastName" => "last_name",
        "email" => "email",
        "roles" => "roles",
        "allAppsVisible" => "all_apps_visible",
        "provisioningAllowed" => "provisioning_allowed",

        "visibleApps" => "visible_apps"
      })

      ESSENTIAL_INCLUDES = [
        "visibleApps"
      ].join(",")
      
      module UserRole
        ADMIN = "ADMIN"
        FINANCE = "FINANCE"
        TECHNICAL = "TECHNICAL"
        SALES = "SALES"
        MARKETING = "MARKETING"
        DEVELOPER = "DEVELOPER"
        ACCOUNT_HOLDER = "ACCOUNT_HOLDER"
        READ_ONLY = "READ_ONLY"
        APP_MANAGER = "APP_MANAGER"
        ACCESS_TO_REPORTS = "ACCESS_TO_REPORTS"
        CUSTOMER_SUPPORT = "CUSTOMER_SUPPORT"
      end

      def self.type
        return "userInvitations"
      end

      #
      # Managing invitations
      #

      def self.all(client: nil, filter: {}, includes: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_user_invitations(filter: filter, includes: includes, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(client: nil, email: nil, includes: nil)
        client ||= Spaceship::ConnectAPI
        return all(client: client, filter: { email: email }, includes: includes)
      end

      def self.create(client: nil, email: nil, first_name: nil, last_name: nil, roles: [], provisioning_allowed: nil, all_apps_visible: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_user_invitation(
          email: email,
          first_name: first_name,
          last_name: last_name,
          roles: roles,
          provisioning_allowed: provisioning_allowed,
          all_apps_visible: all_apps_visible
        )
        return resp.to_models.first
      end

      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_user_invitation(user_invitation_id: id)
      end
    end
  end
end
