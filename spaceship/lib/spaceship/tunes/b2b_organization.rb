require_relative 'tunes_base'
module Spaceship
  module Tunes
    class B2bOrganization < TunesBase
      # @return (String) add or remove
      attr_accessor :type

      # @return (String) customer id
      attr_accessor :dep_customer_id

      # @return (String) organization id
      attr_accessor :dep_organization_id

      # @return (String) organization name
      attr_accessor :name

      # enum for types
      class TYPE
        ADD = "ADD"
        REMOVE = "REMOVE"
        NO_CHANGE = "NO_CHANGE"
      end

      attr_mapping(
        'value.type' => :type,
        'value.depCustomerId' => :dep_customer_id,
        'value.organizationId' => :dep_organization_id,
        'value.name' => :name
      )

      def self.from_id_info(dep_id: nil, dep_org_id: nil, dep_name: nil, type: TYPE::NO_CHANGE)
        self.new({ "value" => { "type" => type, "depCustomerId" => dep_id, "organizationId" => dep_org_id, "name" => dep_name } })
      end

      def ==(other)
        other.class == self.class && other.state == self.state
      end

      def state
        return [type, dep_customer_id, name]
      end

      alias eql? ==

      def hash
        state.hash
      end
    end
  end
end
