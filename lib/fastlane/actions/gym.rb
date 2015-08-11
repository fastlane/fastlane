module Fastlane
  module Actions
    module SharedValues
      IPA_OUTPUT_PATH = :IPA_OUTPUT_PATH
      DSYM_OUTPUT_PATH = :DSYM_OUTPUT_PATH
    end

    class GymAction < Action
      def self.run(values)
        require 'gym'

        begin
          # FastlaneCore::UpdateChecker.start_looking_for_update('gym') unless Helper.is_test?

          Gym.config = values # we alread have the finished config

          path = Gym::Manager.new.work
          dsym_path = path.gsub(".ipa", ".app.dSYM.zip")

          Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = path # absolute path
          Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = dsym_path if File.exist?(dsym_path)

          return path
        ensure
          # FastlaneCore::UpdateChecker.show_update_status('gym', Gym::VERSION)
        end
      end

      def self.description
        "Easily build and sign your app using `gym`"
      end

      def self.author
        "KrauseFx"
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
