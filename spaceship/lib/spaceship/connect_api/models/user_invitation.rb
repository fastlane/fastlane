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
        "username" => "username",
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

      # Get all invited users (not yet accepted)
      def get_user_invitation(filter: {}, includes: nil, limit: nil, sort: nil)
        params = users_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        users_request_client.get("userInvitations", params)
      end

      # Invite new users to App Store Connect
      def post_user_invitation(email: nil, first_name: nil, last_name: nil, roles: [], provisioning_allowed: nil, all_apps_visible: nil)
        body = {
          data: {
            type: "userInvitations",
            attributes: {
              email: email,
              firstName: first_name,
              lastName: last_name,
              roles: roles,
              provisioningAllowed: provisioning_allowed,
              allAppsVisible: all_apps_visible
            }
          }
        }
        users_request_client.post("userInvitations", body)
      end

      # Remove invited user from team (not yet accepted)
      def delete_user_invitation(user_id: nil)
        users_request_client.delete("userInvitations/#{user_id}")
      end

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
