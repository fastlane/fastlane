module Spaceship
  class PortalBase < Spaceship::Base
    class << self
      def client
        (
          @client or
          Spaceship::Portal.client or
          raise "Please login using `Spaceship::Portal.login('user', 'password')`"
        )
      end
    end
  end
end
