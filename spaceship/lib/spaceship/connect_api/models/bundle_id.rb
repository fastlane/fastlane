require_relative '../model'
module Spaceship
  class ConnectAPI
    class BundleId
      include Spaceship::ConnectAPI::Model

      attr_accessor :identifier
      attr_accessor :name
      attr_accessor :seed_id
      attr_accessor :platform

      attr_accessor :bundle_id_capabilities

      attr_mapping({
        "identifier" => "identifier",
        "name" => "name",
        "seedId" => "seed_id",
        "platform" => "platform",

        "bundleIdCapabilities" => 'bundle_id_capabilities'
      })

      def self.type
        return "bundleIds"
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_bundle_ids(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(identifier, platform: nil)
        return all(filter: { identifier: identifier, platform: platform }).find do |app|
          app.identifier == identifier
        end
      end

      def self.get(bundle_id_id: nil, includes: nil)
        return Spaceship::ConnectAPI.get_bundle_id(bundle_id_id: bundle_id_id, includes: includes).first
      end
    end
  end
end
