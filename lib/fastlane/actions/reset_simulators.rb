module Fastlane
  module Actions
    class ResetSimulatorsAction < Action
      def self.run(params)
        Helper.log.info 'Quitting the iOS Simulator app'.green
        sh "osascript -e 'tell application \"iOS Simulator\" to quit'"

        Helper.log.info 'Resetting the contents of all the simulators'.green
        sh "xcrun simctl list devices | grep -v '^[-=]' | cut -d \"(\" -f2 | cut -d \")\" -f1 | xargs -I {} xcrun simctl erase \"{}\" || true"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Closes the iOS Simulator app and resets the contents of all the existing simulators'
      end

      def self.details
        'You can use this action to reset the simulators to a clean state before running tests or using snapshot'
      end

      def self.available_options
        [
        ]
      end

      def self.author
        '@vittoriom'
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
