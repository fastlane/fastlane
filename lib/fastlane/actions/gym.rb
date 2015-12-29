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
          FastlaneCore::UpdateChecker.start_looking_for_update('gym') unless Helper.is_test?

          if values[:provisioning_profile_path].to_s.length == 0
            sigh_path = Actions.lane_context[Actions::SharedValues::SIGH_PROFILE_PATH] || ENV["SIGH_PROFILE_PATH"]
            values[:provisioning_profile_path] = File.expand_path(sigh_path) if sigh_path
          end

          values[:export_method] ||= Actions.lane_context[Actions::SharedValues::SIGH_PROFILE_TYPE]

          absolute_ipa_path = File.expand_path(Gym::Manager.new.work(values))
          absolute_dsym_path = absolute_ipa_path.gsub(".ipa", ".app.dSYM.zip")

          Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = absolute_ipa_path
          Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = absolute_dsym_path if File.exist?(absolute_dsym_path)
          Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE] = Gym::BuildCommandGenerator.archive_path
          ENV[SharedValues::IPA_OUTPUT_PATH.to_s] = absolute_ipa_path # for deliver
          ENV[SharedValues::DSYM_OUTPUT_PATH.to_s] = absolute_dsym_path if File.exist?(absolute_dsym_path)

          return absolute_ipa_path
        ensure
          FastlaneCore::UpdateChecker.show_update_status('gym', Gym::VERSION)
        end
      end

      def self.description
        "Easily build and sign your app using `gym`"
      end

      def self.details
        "More information: https://github.com/fastlane/gym"
      end

      def self.return_value
        "The absolute path to the generated ipa file"
      end

      def self.author
        "KrauseFx"
      end

      def self.available_options
        require 'gym'
        Gym::Options.available_options
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
