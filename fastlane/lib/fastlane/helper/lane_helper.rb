module Fastlane
  module Helper
    class LaneHelper
      def self.current_platform
        return Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::PLATFORM_NAME]
      end

      def self.current_lane
        return Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME]
      end
    end
  end
end
