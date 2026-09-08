require_relative '../model'

module Spaceship
  class ConnectAPI
    class PassTypeId
      include Spaceship::ConnectAPI::Model

      attr_accessor :identifier
      attr_accessor :name

      attr_mapping({
        "identifier" => "identifier",
        "name" => "name"
      })

      def self.type
        return "passTypeIds"
      end

      #
      # API
      #

      # rubocop:disable Require/MissingRequireStatement
      def self.all(client: nil, filter: {}, includes: nil, fields: nil, limit: Spaceship::ConnectAPI::MAX_OBJECTS_PER_PAGE_LIMIT, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_pass_type_ids(filter: filter, includes: includes, fields: fields, limit: limit, sort: sort).all_pages
        return resps.flat_map(&:to_models)
      end
      # rubocop:enable Require/MissingRequireStatement

      def self.find(identifier, client: nil)
        client ||= Spaceship::ConnectAPI
        return all(client: client).find do |pass_type_id|
          pass_type_id.identifier == identifier
        end
      end
    end
  end
end
