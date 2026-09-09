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
          client.merchants(mac: mac).map { |merchant| new_with_platform(merchant, mac) }
        end

        # Creates a new Merchant on the Apple Dev Portal
        #
        # @param bundle_id [String] the bundle id (merchant_identifier) of the merchant
        # @param name [String] the name of the Merchant
        # @param mac [Bool] is this a Mac Merchant?
        # @return (Merchant) The Merchant you just created
        def create!(bundle_id: nil, name: nil, mac: false)
          new_merchant = client.create_merchant!(name, bundle_id, mac: mac)
          new_with_platform(new_merchant, mac)
        end

        # Find a specific Merchant ID based on the bundle_id
        # @param mac [Bool] Searches Mac merchants if true
        # @return (Merchant) The Merchant you're looking for. This is nil if the merchant can't be found.
        def find(bundle_id, mac: false)
          all(mac: mac).find do |merchant|
            merchant.bundle_id == bundle_id
          end
        end

        # Apple does not return the platform, so we record the one that was asked for.
        def new_with_platform(attrs, mac)
          new(attrs).tap { |merchant| merchant.platform = mac ? 'mac' : 'ios' }
        end
        private :new_with_platform
      end

      # Represents a domain registered to an Apple Pay Merchant ID
      class Domain < PortalBase
        # @return (String) The identifier of this domain, provided by the Dev Portal
        # @example
        #   "UFVN6788YA"
        attr_accessor :domain_id

        # @return (String) The domain name you registered
        # @example
        #   "krausefx.com"
        attr_accessor :name

        # @return (String) Status of the domain verification
        # @example
        #   "verified"
        attr_accessor :status

        # @return (String) The URL Apple expects to serve the domain association file
        # @example
        #   "https://krausefx.com/.well-known/apple-developer-merchantid-domain-association.txt"
        attr_accessor :path

        # @return (Bool) Can this domain be verified by the current team?
        attr_accessor :can_verify

        # @return (String) The date this domain's verification expires
        # @example
        #   "2026-10-11"
        attr_accessor :expiration_date

        # @return (String) A human readable version of the expiration date
        # @example
        #   "Oct 11, 2026"
        attr_accessor :expiration_date_string

        # @return (Spaceship::Portal::Merchant) The merchant this domain is registered to
        #   This is not part of Apple's response, it gets set by whoever fetched the domain
        attr_accessor :merchant

        attr_mapping(
          'displayId' => :domain_id,
          'name' => :name,
          'status' => :status,
          'path' => :path,
          'canVerify' => :can_verify,
          'expirationDate' => :expiration_date,
          'expirationDateString' => :expiration_date_string
        )

        class << self
          # @param merchant [Merchant] The merchant to fetch the domains of
          # @return (Array) Returns all domains registered to the given merchant
          def all(merchant)
            client.merchant_domains(merchant.merchant_id, mac: merchant.mac?).map do |domain|
              new(domain).tap { |d| d.merchant = merchant }
            end
          end

          # Registers a new domain for a Merchant ID on the Apple Dev Portal
          #
          # @param merchant [Merchant] the merchant to register the domain for
          # @param domain_name [String] the domain name to register
          # @return (Domain) The Domain you just registered
          def create!(merchant: nil, domain_name: nil)
            new_domain = client.create_merchant_domain!(merchant.merchant_id, domain_name, mac: merchant.mac?)
            new(new_domain).tap { |d| d.merchant = merchant }
          end

          # Find a specific domain of a merchant based on the domain name
          #
          # @param merchant [Merchant] The merchant to search the domains of
          # @param name [String] the domain name to look for
          # @return (Domain) The Domain you're looking for. This is nil if the domain can't be found.
          def find(merchant, name)
            all(merchant).find do |domain|
              domain.name == name
            end
          end
        end

        # Delete this Domain
        # @return (Domain) The domain you just deleted
        def delete!
          client.delete_merchant_domain!(domain_id, merchant.merchant_id, mac: merchant.mac?)
          self
        end
      end

      # @return (Array of Spaceship::Portal::Merchant::Domain) The domains registered to this merchant
      def domains
        @domains ||= client.merchant_domains(merchant_id, mac: mac?).map do |domain|
          Domain.new(domain, client).tap { |d| d.merchant = self }
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
