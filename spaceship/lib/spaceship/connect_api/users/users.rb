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
    end
  end
end
