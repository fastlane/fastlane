module Fastlane
  module Actions
    require 'fastlane/actions/build_app'
    class GymAction < BuildAppAction
      def self.description
        "Alias for the `build_app` action"
      end
    end
  end
end
