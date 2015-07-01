module Spaceship
  class PortalBase < Spaceship::Base
    class << self
      def client
        @client || Spaceship::Portal.client
      end
    end
  end
end