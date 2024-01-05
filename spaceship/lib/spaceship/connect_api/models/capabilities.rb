require_relative '../model'

module Spaceship
  class ConnectAPI
    class Capabilities
      include Spaceship::ConnectAPI::Model

      attr_accessor :name
      attr_accessor :description

      attr_mapping({
        "name" => "name",
        "description" => "description",
      })

      def self.type
        return "capabilities"
      end

      def self.all(client: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_available_bundle_id_capabilities(bundle_id_id: id).all_pages
        return resp.flat_map(&:to_models)
      end
    end
  end
end
