require_relative "display_family"

module Spaceship
  module Tunes
    # identifiers of devices that App Store Connect accepts screenshots for
    class DeviceType
      def self.types
        return DisplayFamily.all_families.keys.map(&:to_s)
      end

      def self.exists?(type)
        types.include?(type)
      end
    end
  end
end
