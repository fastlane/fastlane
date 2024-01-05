require_relative 'portal_base'

module Spaceship
  module Portal
    # Represents a Merchant ID from the Developer Portal
    class Merchant < PortalBase
      # @return (String) The identifier of this merchant, provided by the Dev Portal
      # @example
      #   "LM1UX73BAC"
      attr_accessor :merchant_id

      # @return (String) The name you provided for this merchant
      # @example
      #   "Spaceship Production"
      attr_accessor :name

      # @return (String) the supported platform of this merchant
      # @example
      #   "ios"
      attr_accessor :platform

      # Prefix provided by the Dev Portal
      # @example
      #   "5A9972XTK2"
      attr_accessor :prefix

      # @return (String) The bundle_id (merchant identifier) of merchant id
      # @example
      #   "merchant.com.krausefx.app.production"
      attr_accessor :bundle_id

      # @return (String) Status of the merchant
      # @example
      #   "current"
      attr_accessor :status

      attr_mapping(
        'omcId' => :merchant_id,
        'name' => :name,
        'prefix' => :prefix,
        'identifier' => :bundle_id,
        'status' => :status
      )

      class << self
        # @param mac [Bool] Fetches Mac merchant if true
        # @return (Array) Returns all merchants available for this account
        def all(mac: false)
          client.merchants(mac: mac).map { |merchant| new(merchant) }
        end

        # Creates a new Merchant on the Apple Dev Portal
        #
        # @param bundle_id [String] the bundle id (merchant_identifier) of the merchant
        # @param name [String] the name of the Merchant
        # @param mac [Bool] is this a Mac Merchant?
        # @return (Merchant) The Merchant you just created
        def create!(bundle_id: nil, name: nil, mac: false)
          new_merchant = client.create_merchant!(name, bundle_id, mac: mac)
          new(new_merchant)
        end

        # Find a specific Merchant ID based on the bundle_id
        # @param mac [Bool] Searches Mac merchants if true
        # @return (Merchant) The Merchant you're looking for. This is nil if the merchant can't be found.
        def find(bundle_id, mac: false)
          all(mac: mac).find do |merchant|
            merchant.bundle_id == bundle_id
          end
        end
      end

      # Delete this Merchant
      # @return (Merchant) The merchant you just deleted
      def delete!
        client.delete_merchant!(merchant_id, mac: mac?)
        self
      end

      # @return (Bool) Is this a Mac merchant?
      def mac?
        platform == 'mac'
      end
    end
  end
end
