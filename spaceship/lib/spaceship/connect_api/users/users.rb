require 'spaceship/connect_api/users/client'

module Spaceship
  class ConnectAPI
    module Users
      #
      # users
      #

      def get_users(filter: {}, includes: nil, limit: nil, sort: nil)
        params = Client.instance.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        Client.instance.get("users", params)
      end

      def add_user_visible_apps(user_id: nil, app_ids: nil)
        body = {
          data: app_ids.map do |app_id|
            {
              type: "apps",
              id: app_id
            }
          end
        }

        Client.instance.post("users/#{user_id}/relationships/visibleApps", body)
      end
    end
  end
end
