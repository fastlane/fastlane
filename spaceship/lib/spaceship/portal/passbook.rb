require_relative 'portal_base'

module Spaceship
  module Portal
    # Represents an Passbook ID from the Developer Portal
    class Passbook < PortalBase
      # @return (String) The identifier of this passbook, provided by the Dev Portal
      # @example
      #   "RGAWZGXSAA"
      attr_accessor :passbook_id

      # @return (String) The name you provided for this passbook
      # @example
      #   "Spaceship"
      attr_accessor :name

      # @return (String) the supported platform of this passbook
      # @example
      #   "ios"
      attr_accessor :platform

      # Prefix provided by the Dev Portal
      # @example
      #   "5A997XSHK2"
      attr_accessor :prefix

      # @return (String) The bundle_id (passbook) of passbook id
      # @example
      #   "web.com.krausefx.app"
      attr_accessor :bundle_id

      # @return (String) Status of the passbook
      # @example
      #   "current"
      attr_accessor :status

      attr_mapping(
        'passTypeId' => :passbook_id,
        'name' => :name,
        'prefix' => :prefix,
        'identifier' => :bundle_id,
        'status' => :status
      )

      class << self
        # @return (Array) Returns all passbook available for this account
        def all
          client.passbooks.map { |pass_type| self.new(pass_type) }
        end

        # Creates a new Passbook ID on the Apple Dev Portal
        #
        # @param bundle_id [String] the bundle id (Passbook_id) of the passbook
        # @param name [String] the name of the Passbook
        # @return (Passbook) The Passbook you just created
        def create!(bundle_id: nil, name: nil)
          new_passbook = client.create_passbook!(name, bundle_id)
          self.new(new_passbook)
        end

        # Find a specific Passbook ID based on the bundle_id
        # @return (Passbook) The passbook you're looking for. This is nil if the passbook can't be found.
        def find(bundle_id)
          all.find do |passbook|
            passbook.bundle_id == bundle_id
          end
        end
      end

      # Delete this Passbook ID.
      # @return (Passbook) The passbook you just deleted
      def delete!
        client.delete_passbook!(passbook_id)
        self
      end
    end
  end
end
