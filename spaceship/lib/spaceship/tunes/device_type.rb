require_relative "device_media_definition"

module Spaceship
  module Tunes
    # identifiers of devices that App Store Connect accepts screenshots for
    class DeviceType
      def self.types
        return DeviceMediaDefinition.all_definitions.keys.map(&:to_s)
      end

      def self.exists?(type)
        types.include?(type)
      end
    end
  end
end
