require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppStoreVersionReleaseRequest
      include Spaceship::ConnectAPI::Model

      def self.type
        return "appStoreVersionReleaseRequests"
      end
    end
  end
end
