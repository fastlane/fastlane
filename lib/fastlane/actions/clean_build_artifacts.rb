module Fastlane
  module Actions
    class CleanBuildArtifactsAction < Action
      def self.run(params)
        [
          Actions.lane_context[Actions::SharedValues::IPA_OUTPUT_PATH],
          Actions.lane_context[Actions::SharedValues::SIGH_PROFILE_PATH],
          Actions.lane_context[Actions::SharedValues::DSYM_OUTPUT_PATH],
        ].reject { |file| file.nil? || !File.exist?(file) }.each { |file| File.delete(file) }

        Helper.log.info 'Cleaned up build artifacts 🐙'.green
      end

      def self.description
        "Deletes files created as result of running ipa or sigh"
      end

      def self.author
        "lmirosevic"
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
