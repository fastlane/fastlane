require 'spaceship/connect_api/users/client'

module Spaceship
  class ConnectAPI
    module Users
      module API
        def users_request_client=(users_request_client)
          @users_request_client = users_request_client
        end

        def users_request_client
          return @users_request_client if @users_request_client
          raise TypeError, "You need to instantiate this module with users_request_client"
        end

        #
        # users
        #

        # Get list of users
        def get_users(filter: {}, includes: nil, limit: nil, sort: nil)
          params = users_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          users_request_client.get("users", params)
        end

        # Delete existing user
        def delete_user(user_id: nil)
          users_request_client.delete("users/#{user_id}")
        end

        # Change app permissions for user
        def add_user_visible_apps(user_id: nil, app_ids: nil)
          body = {
            data: app_ids.map do |app_id|
              {
                type: "apps",
                id: app_id
              }
            end
          }

          users_request_client.post("users/#{user_id}/relationships/visibleApps", body)
        end

        #
        # invitations (invited users)
        #

        # Get all invited users (not yet accepted)
        def get_user_invitations(filter: {}, includes: nil, limit: nil, sort: nil)
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
        def delete_user_invitation(user_invitation_id: nil)
          users_request_client.delete("userInvitations/#{user_invitation_id}")
        end
      end
    end
  end
end
