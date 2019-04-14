require_relative "display_family"

module Spaceship
  module Tunes
    # identifiers of devices that App Store Connect accepts screenshots for
    class DeviceType
      def self.types
        UI.deprecated("Spaceship::Tunes::DeviceType has been deprecated. Use the new Spaceship::Tunes::DisplayFamily class instead")
        return DisplayFamily.all.map(&:name)
      end

      def self.exists?(type)
        types.include?(type)
      end
    end
  end
end
