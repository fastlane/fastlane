module Fastlane
  module Actions
    class CleanBuildArtifactsAction
      
      def self.is_supported?(type)
        type == :ios
      end

      def self.run(_params)
        [
          Actions.lane_context[Actions::SharedValues::IPA_OUTPUT_PATH],
          Actions.lane_context[Actions::SharedValues::SIGH_PROFILE_PATH],
          Actions.lane_context[Actions::SharedValues::DSYM_OUTPUT_PATH],
        ].reject { |file| file.nil? || !File.exist?(file) }.each { |file| File.delete(file) }

        Helper.log.info 'Cleaned up build artifacts 🐙'.green
      end
    end
  end
end
