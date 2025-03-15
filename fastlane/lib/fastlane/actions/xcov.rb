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
          "More information: [https://github.com/nakiostudio/xcov](https://github.com/nakiostudio/xcov)."
        ].join("\n")
      end

      def self.author
        "nakiostudio"
      end

      def self.available_options
        return [] unless Helper.mac?

        # We call Gem::Specification.find_by_name in many more places than this, but for right now
        # this is the only place we're having trouble. If there are other reports about RubyGems
        # 2.6.2 causing problems, we may need to move this code and require it someplace better,
        # like fastlane_core
        require 'fastlane/core_ext/bundler_monkey_patch'

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
