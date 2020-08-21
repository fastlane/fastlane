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

        def get_users(filter: {}, includes: nil, limit: nil, sort: nil)
          params = users_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          users_request_client.get("users", params)
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

          users_request_client.post("users/#{user_id}/relationships/visibleApps", body)
        end
      end
    end
  end
end
