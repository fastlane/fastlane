require 'spaceship/connect_api/users/client'
require 'spaceship/connect_api/users/base'

require 'spaceship/connect_api/users/models/user'

module Spaceship
  module ConnectAPI
    module Users
      def self.client
        return Spaceship::ConnectAPI::Users::Base.client
      end
    end
  end
end
