require_relative '../model'
module Spaceship
  class ConnectAPI
    class BundleId
      include Spaceship::ConnectAPI::Model

      attr_accessor :identifier
      attr_accessor :name
      attr_accessor :seed_id
      attr_accessor :platform

      attr_mapping({
        "identifier" => "identifier",
        "name" => "name",
        "seedId" => "seed_id",
        "platform" => "platform"
      })

      module Platform
        IOS = "IOS"
        MAC_OS = "MAC_OS"
      end

      def self.type
        return "bundleIds"
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_bundle_ids(filter: filter, includes: includes).all_pages
        return resps.map(&:to_models).flatten
      end
    end
  end
end
