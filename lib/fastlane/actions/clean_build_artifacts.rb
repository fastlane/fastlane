module Fastlane
  module Actions
    class CleanBuildArtifactsAction < Action
      def self.run(options)
        paths = [
          Actions.lane_context[Actions::SharedValues::IPA_OUTPUT_PATH],
          Actions.lane_context[Actions::SharedValues::DSYM_OUTPUT_PATH]
        ]

        paths += Actions.lane_context[Actions::SharedValues::SIGH_PROFILE_PATHS] || []

        paths.reject { |file| file.nil? || !File.exist?(file) }.each do |file|
          if options[:exclude_pattern]
            next if file.match(options[:exclude_pattern])
          end

          Helper.log.debug "Cleaning up '#{file}'".yellow
          File.delete(file)
        end

        Helper.log.info 'Cleaned up build artifacts 🐙'.green
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :exclude_pattern,
                                       env_name: "FL_CLEAN_BUILD_ARTIFACTS_EXCLUDE_PATTERN",
                                       description: "Exclude all files from clearing that match the given Regex pattern: e.g. '.*\.mobileprovision'",
                                       default_value: nil,
                                       optional: true)
        ]
      end

      def self.description
        "Deletes files created as result of running ipa or sigh"
      end

      def self.author
        "lmirosevic"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
