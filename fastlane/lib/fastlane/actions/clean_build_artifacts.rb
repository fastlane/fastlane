module Fastlane
  module Actions
    class CleanBuildArtifactsAction < Action
      def self.run(options)
        paths = [
          Actions.lane_context[Actions::SharedValues::IPA_OUTPUT_PATH],
          Actions.lane_context[Actions::SharedValues::DSYM_OUTPUT_PATH],
          Actions.lane_context[Actions::SharedValues::CERT_FILE_PATH]
        ]

        paths += Actions.lane_context[Actions::SharedValues::SIGH_PROFILE_PATHS] || []
        paths += Actions.lane_context[Actions::SharedValues::DSYM_PATHS] || []
        paths = paths.uniq

        paths.reject { |file| file.nil? || !File.exist?(file) }.each do |file|
          if options[:exclude_pattern]
            next if file.match(options[:exclude_pattern])
          end

          UI.verbose("Cleaning up '#{file}'")
          File.delete(file)
        end

        UI.success('Cleaned up build artifacts 🐙')
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
        "Deletes files created as result of running gym, cert, sigh or download_dsyms"
      end

      def self.details
        [
          "This action deletes the files that get created in your repo as a result of running the _gym_ and _sigh_ commands. It doesn't delete the `fastlane/report.xml` though, this is probably more suited for the .gitignore.",
          "",
          "Useful if you quickly want to send out a test build by dropping down to the command line and typing something like `fastlane beta`, without leaving your repo in a messy state afterwards."
        ].join("\n")
      end

      def self.author
        "lmirosevic"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'clean_build_artifacts'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
