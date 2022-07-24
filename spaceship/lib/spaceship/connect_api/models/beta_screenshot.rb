require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaScreenshot
      include Spaceship::ConnectAPI::Model

      attr_accessor :image_assets

      attr_mapping({
        "imageAssets" => "image_assets"
      })

      def self.type
        return "betaScreenshots"
      end
    end
  end
end
