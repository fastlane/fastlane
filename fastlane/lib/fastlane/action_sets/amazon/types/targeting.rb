module Fastlane::ActionSets::Amazon
  # Describes availability for an `Edit`.
  class Targeting
    class Device
      class Reason
        # @return [String] The description of the reason as to why this isn't
        #   supported
        attr_accessor :reason
        # @return [Array<String>] Any further reasons why this isn't supported
        attr_accessor :details

        # @param [Hash] json
        def initialize(json)
          @reason = json['reason']
          @details = json['details']
        end

        # @return [Hash]
        def to_json
          { 'reason' => reason, 'details' => details }
        end

        # @param [Reason] other
        # @return [Boolean]
        def ==(other)
          reason == other.reason && details == other.details
        end

        def to_s
          "<Fastlane::ActionSets::Amazon::Targeting::Device::Reason:#{object_id} reason=>\"#{reason}\">"
        end
      end

      # @return [String] The unique identifier for the device class
      attr_accessor :id
      # @return [String] The name of the device class
      attr_accessor :name
      # @return [String] The targeting status of this device class; `DISABLED`
      #   or `TARGETING` usually
      attr_accessor :status
      # @return [Reason] If disabled, the reason this was disabled
      attr_accessor :reason

      # @param [Hash] json
      def initialize(json)
        @id = json['id']
        @name = json['name']
        @status = json['status']
        @reason = json['reason'].empty? ? nil : Reason.new(json['reason'])
      end

      # @return [Hash]
      def to_json
        {
          'id' => id,
          'name' => name,
          'status' => status,
          'reason' => reason ? reason.to_json : {}
        }
      end

      # @param [Device] other
      # @return [Boolean]
      def ==(other)
        id == other.id &&
          name == other.name &&
          status == other.status &&
          reason == other.reason
      end

      def to_s
        "<Fastlane::ActionSets::Amazon::Targeting::Device:#{object_id} id=>\"#{id}\" name=>\"#{name}\" status=>\"#{status}\">"
      end
    end

    # @return [Array<Device>]
    attr_accessor :amazon_devices
    # @return [Array<Device>]
    attr_accessor :non_amazon_devices

    # @param [Hash] json
    def initialize(json)
      @amazon_devices = json['amazonDevices'].map { |j| Device.new(j) }
      @non_amazon_devices = json['nonAmazonDevices'].map { |j| Device.new(j) }
    end

    # @return [Hash]
    def to_json
      {
        'amazonDevices' => amazon_devices.map(&:to_json),
        'nonAmazonDevices' => non_amazon_devices.map(&:to_json),
      }
    end

    # @param [Availability] other
    # @return [Boolean]
    def ==(other)
      amazon_devices == other.amazon_devices &&
        non_amazon_devices == other.non_amazon_devices
    end

    def to_s
      "<Fastlane::ActionSets::Amazon::Targeting:#{object_id} amazon_devices=>#{amazon_devices} non_amazon_devices=>#{non_amazon_devices}>"
    end
  end
end
