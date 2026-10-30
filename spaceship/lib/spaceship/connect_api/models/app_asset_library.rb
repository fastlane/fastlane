require_relative '../model'

module Spaceship
  class ConnectAPI
    class AppAssetLibrary
      include Spaceship::ConnectAPI::Model

      def self.type
        return 'appAssetLibraries'
      end

      def self.get(client: nil, app_id:)
        client ||= Spaceship::ConnectAPI
        return client.get_app_asset_library(app_id: app_id).first
      end
    end
  end
end
