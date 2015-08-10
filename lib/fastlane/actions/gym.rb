module Fastlane
  module Actions
    module SharedValues
    end

    class GymAction < Action
      def self.run(values)
        require 'gym'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('gym') unless Helper.is_test?

          Gym::Manager.new.work(values)
        ensure
          FastlaneCore::UpdateChecker.show_update_status('gym', Gym::VERSION)
        end
      end

      def self.description
        "Easily build and sign your app using `gym`"
      end

      def self.author
        "fabiomassimo"
      end

      def self.available_options
        require 'gym'

        Gym::Options.available_options
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
