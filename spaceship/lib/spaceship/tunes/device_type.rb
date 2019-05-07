require_relative "display_family"

module Spaceship
  module Tunes
    # identifiers of devices that App Store Connect accepts screenshots for
    class DeviceType
      def self.types
        warn("Spaceship::Tunes::DeviceType has been deprecated, use Spaceship::Tunes::DisplayFamily instead. (https://github.com/fastlane/fastlane/pull/14574).")
        return DisplayFamily.all.map(&:name)
      end

      def self.exists?(type)
        types.include?(type)
      end
    end
  end
end
