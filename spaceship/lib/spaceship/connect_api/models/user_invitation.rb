require_relative '../model'
require_relative 'user'

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

      UserRole = Spaceship::ConnectAPI::User::UserRole

      def self.type
        return "userInvitations"
      end

      #
      # Managing invitations
      #

      def self.all(client: nil, filter: {}, includes: ESSENTIAL_INCLUDES, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_user_invitations(filter: filter, includes: includes, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(client: nil, email: nil, includes: ESSENTIAL_INCLUDES)
        client ||= Spaceship::ConnectAPI
        return all(client: client, filter: { email: email }, includes: includes)
      end

      # Create and post user invitation
      # App Store Connect allows for the following combinations of `all_apps_visible` and `visible_app_ids`:
      # - if `all_apps_visible` is `nil`, you don't have to provide values for `visible_app_ids`
      # - if `all_apps_visible` is false, you must provide values for `visible_app_ids`.
      # - if `all_apps_visible` is true, you must not provide values for `visible_app_ids`.
      def self.create(client: nil, email: nil, first_name: nil, last_name: nil, roles: [], provisioning_allowed: nil, all_apps_visible: nil, visible_app_ids: [])
        client ||= Spaceship::ConnectAPI
        resp = client.post_user_invitation(
          email: email,
          first_name: first_name,
          last_name: last_name,
          roles: roles,
          provisioning_allowed: provisioning_allowed,
          all_apps_visible: all_apps_visible,
          visible_app_ids: visible_app_ids
        )
        return resp.to_models.first
      end

      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_user_invitation(user_invitation_id: id)
      end

      # Get visible apps for invited user
      def get_visible_apps(client: nil, limit: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_user_invitation_visible_apps(user_invitation_id: id, limit: limit)
        return resp.to_models
      end
    end
  end
end
