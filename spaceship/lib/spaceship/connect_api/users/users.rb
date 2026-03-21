require 'spaceship/connect_api/users/client'

module Spaceship
  class ConnectAPI
    module Users
      module API
        module Version
          V1 = "v1"
        end

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
          users_request_client.get("#{Version::V1}/users", params)
        end

        # Delete existing user
        def delete_user(user_id: nil)
          users_request_client.delete("#{Version::V1}/users/#{user_id}")
        end

        # Update existing user
        def patch_user(user_id:, all_apps_visible:, provisioning_allowed:, roles:, visible_app_ids:)
          body = {
            data: {
              type: 'users',
              id: user_id,
              attributes: {
                allAppsVisible: all_apps_visible,
                provisioningAllowed: provisioning_allowed,
                roles: roles
              },
              relationships: {
                visibleApps: {
                  data: visible_app_ids.map do |app_id|
                    {
                      type: "apps",
                      id: app_id
                    }
                  end
                }
              }
            }
          }

          # Avoid API error: You cannot set visible apps for this user because the user's roles give them access to all apps.
          body[:data].delete(:relationships) if all_apps_visible

          users_request_client.patch("#{Version::V1}/users/#{user_id}", body)
        end

        # Add app permissions for user
        # @deprecated Use {#post_user_visible_apps} instead.
        def add_user_visible_apps(user_id: nil, app_ids: nil)
          post_user_visible_apps(user_id: user_id, app_ids: app_ids)
        end

        def post_user_visible_apps(user_id: nil, app_ids: nil)
          body = {
            data: app_ids.map do |app_id|
              {
                type: "apps",
                id: app_id
              }
            end
          }

          users_request_client.post("#{Version::V1}/users/#{user_id}/relationships/visibleApps", body)
        end

        # Replace app permissions for user
        def patch_user_visible_apps(user_id: nil, app_ids: nil)
          body = {
            data: app_ids.map do |app_id|
              {
                type: "apps",
                id: app_id
              }
            end
          }

          users_request_client.patch("#{Version::V1}/users/#{user_id}/relationships/visibleApps", body)
        end

        # Remove app permissions for user
        def delete_user_visible_apps(user_id: nil, app_ids: nil)
          body = {
            data: app_ids.map do |app_id|
              {
                type: "apps",
                id: app_id
              }
            end
          }
          params = nil
          users_request_client.delete("#{Version::V1}/users/#{user_id}/relationships/visibleApps", params, body)
        end

        # Get app permissions for user
        def get_user_visible_apps(user_id: id, limit: nil)
          params = users_request_client.build_params(filter: {}, includes: nil, limit: limit, sort: nil)
          users_request_client.get("#{Version::V1}/users/#{user_id}/visibleApps", params)
        end

        #
        # invitations (invited users)
        #

        # Get all invited users
        def get_user_invitations(filter: {}, includes: nil, limit: nil, sort: nil)
          params = users_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          users_request_client.get("#{Version::V1}/userInvitations", params)
        end

        # Invite new users to App Store Connect
        def post_user_invitation(email: nil, first_name: nil, last_name: nil, roles: [], provisioning_allowed: nil, all_apps_visible: nil, visible_app_ids: [])
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
              },
              relationships: {
                visibleApps: {
                  data: visible_app_ids.map do |id|
                    {
                      id: id,
                      type: "apps"
                    }
                  end
                }
              }
            }
          }

          # Avoid API error: You cannot set visible apps for this user because the user's roles give them access to all apps.
          body[:data].delete(:relationships) if all_apps_visible

          users_request_client.post("#{Version::V1}/userInvitations", body)
        end

        # Remove invited user from team (not yet accepted)
        def delete_user_invitation(user_invitation_id: nil)
          users_request_client.delete("#{Version::V1}/userInvitations/#{user_invitation_id}")
        end

        # Get all app permissions for invited user
        def get_user_invitation_visible_apps(user_invitation_id: id, limit: nil)
          params = users_request_client.build_params(filter: {}, includes: nil, limit: limit, sort: nil)
          users_request_client.get("#{Version::V1}/userInvitations/#{user_invitation_id}/visibleApps", params)
        end
      end
    end
  end
end
