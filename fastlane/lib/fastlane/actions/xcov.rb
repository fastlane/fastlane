module Fastlane
  module Actions
    class XcovAction < Action
      def self.run(values)
        Actions.verify_gem!('xcov')
        require 'xcov'

        if values[:xccov_file_direct_path].nil? && (path = Actions.lane_context[SharedValues::SCAN_GENERATED_XCRESULT_PATH])
          UI.verbose("Pulling xcov 'xccov_file_direct_path' from SharedValues::SCAN_GENERATED_XCRESULT_PATH")
          values[:xccov_file_direct_path] = path
        end

        Xcov::Manager.new(values).run
      end

      def self.description
        "Nice code coverage reports without hassle"
      end

      def self.details
        [
          "Create nice code coverage reports and post coverage summaries on Slack *(xcov gem is required)*.",
          "More information: [https://github.com/fastlane-community/xcov](https://github.com/fastlane-community/xcov)."
        ].join("\n")
      end

      def self.author
        "nakiostudio"
      end

      def self.available_options
        return [] unless Helper.mac?

        begin
          Gem::Specification.find_by_name('xcov')
        rescue Gem::LoadError
          # Catch missing gem exception and return empty array
          # to avoid unused_options_spec failure
          return []
        end

        require 'xcov'
        Xcov::Options.available_options
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xcov(
            workspace: "YourWorkspace.xcworkspace",
            scheme: "YourScheme",
            output_directory: "xcov_output"
          )'
        ]
      end

      def self.category
        :testing
      end
    end
  end
end
