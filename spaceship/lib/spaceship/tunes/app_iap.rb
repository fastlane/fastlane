module Spaceship
  module Tunes
    # Represents in-app purchases from iTunesConnect
    class AppIAP < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      attr_accessor :application

      # @return (Array) A list of all this IAP versions
      attr_reader :versions

      # @return (String) Reference name (as appears in iTunesConnect and Sales reports)
      attr_reader :reference_name

      # @return (Spaceship::Tunes::IAPStatus) What's the current status of this in-app-purchase
      #   e.g. Missing Metadata, Waiting for Review, Approved, ...
      attr_reader :status

      # @return (String) IAP Status (e.g. 'readyForSale'). You should use `status` instead.
      attr_reader :raw_status

      # @return (Spaceship::Tunes::IAPType) What's the product type of this in-app-purchase
      #   e.g. Consumable, Auto-Renewable Subscription, ...
      attr_reader :type

      # @return (String) IAP Product Type (e.g. 'recurring'). You should use `type` instead.
      attr_reader :raw_type

      # @return (String) The product's unique ID
      attr_reader :vendor_id

      # Subscription-specific parameters
      # @return (Integer) Duration of the subscription (in days)
      attr_reader :duration_days

      attr_mapping({
        'versions' => :versions,
        'referenceName' => :reference_name,
        'iTunesConnectStatus' => :raw_status,
        'addOnType' => :raw_type,
        'vendorId' => :vendor_id,

        'durationDays' => :duration_days
      })

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          obj = self.new(attrs)
          return obj
        end
      end

      # Private methods
      def setup
        # Parse the status
        @status = Tunes::IAPStatus.get_from_string(raw_status)

        # Parse the type
        @type = Tunes::IAPType.get_from_string(raw_type)
      end
    end
  end
end
