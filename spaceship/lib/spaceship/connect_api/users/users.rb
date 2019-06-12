require 'spaceship/connect_api/users/client'

module Spaceship
  class ConnectAPI
    module Users
      #
      # users
      #

      def get_users(filter: {}, includes: nil, limit: nil, sort: nil)
        # GET
        # https://appstoreconnect.apple.com/iris/v1/users
        params = client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
        client.get("users", params)
      end

      private

      def client
        return Spaceship::ConnectAPI::Users::Client.instance
      end
    end
  end
end
