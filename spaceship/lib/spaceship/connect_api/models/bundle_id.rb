require_relative '../model'
require_relative './bundle_id_capability'
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
      # Helpers
      #

      def supports_catalyst?
        return bundle_id_capabilities.any? do |capability|
          capability.is_type?(Spaceship::ConnectAPI::BundleIdCapability::Type::MARZIPAN)
        end
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_bundle_ids(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(identifier, platform: nil, includes: nil)
        return all(filter: { identifier: identifier, platform: platform }, includes: includes).find do |app|
          app.identifier == identifier
        end
      end

      def self.get(bundle_id_id: nil, includes: nil)
        return Spaceship::ConnectAPI.get_bundle_id(bundle_id_id: bundle_id_id, includes: includes).first
      end
    end
  end
end
