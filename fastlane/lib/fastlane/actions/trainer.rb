module Fastlane
  module Actions
    class TrainerAction < Action
      def self.run(params)
        require "trainer"

        params[:path] = Actions.lane_context[Actions::SharedValues::SCAN_GENERATED_PLIST_FILE] if Actions.lane_context[Actions::SharedValues::SCAN_GENERATED_PLIST_FILE]
        params[:path] ||= Actions.lane_context[Actions::SharedValues::SCAN_DERIVED_DATA_PATH] if Actions.lane_context[Actions::SharedValues::SCAN_DERIVED_DATA_PATH]

        fail_build = params[:fail_build]
        resulting_paths = Trainer::TestParser.auto_convert(params)
        resulting_paths.each do |path, test_results|
          UI.test_failure!("Unit tests failed") if fail_build && !test_results[:successful]
        end

        return resulting_paths
      end

      def self.description
        "Convert the Xcode plist log to a JUnit report"
      end

      def self.detail
        "Convert the Xcode plist log to a JUnit report. This will raise an exception if the tests failed"
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.return_value
        "A hash with the key being the path of the generated file, the value being if the tests were successful"
      end

      def self.available_options
        require 'trainer'
        FastlaneCore::CommanderGenerator.new.generate(Trainer::Options.available_options)
      end

      def self.is_supported?(platform)
        %i[ios mac].include?(platform)
      end

      def self.category
        :testing
      end
    end
  end
end
