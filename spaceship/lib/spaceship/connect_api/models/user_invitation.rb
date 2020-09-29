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

      def self.all(filter: {}, includes: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_user_invitations(filter: filter, includes: includes, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(email: nil, includes: nil)
        return all(filter: { email: email }, includes: includes)
      end

      def delete!
        Spaceship::ConnectAPI.delete_user_invitation(user_invitation_id: id)
      end
    end
  end
end
