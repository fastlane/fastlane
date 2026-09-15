require 'json'
require 'open3'

require_relative 'xcresult/helper'
require_relative 'xcresult/test_case_attributes'
require_relative 'xcresult/repetition'
require_relative 'xcresult/test_case'
require_relative 'xcresult/test_suite'
require_relative 'xcresult/test_plan'

module Trainer
  # Model xcresulttool JSON output for Xcode16+ version of xcresulttool
  # See JSON schema from `xcrun xcresulttool get test-results tests --help`
  module XCResult
    module Parser
      class << self
        # Parses an xcresult file and returns a TestPlan object
        #
        # @param path [String] The path to the xcresult file
        # @param output_remove_retry_attempts [Boolean] Whether to remove retry attempts from the output
        # @return [TestPlan] A TestPlan object containing the test results
        def parse_xcresult(path:, output_remove_retry_attempts: false)
          json = xcresult_to_json(path)

          TestPlan.from_json(
            json: json
          ).tap do |test_plan|
            test_plan.output_remove_retry_attempts = output_remove_retry_attempts
          end
        end

        private

        def xcresult_to_json(path)
          stdout, stderr, status = Open3.capture3('xcrun', 'xcresulttool', 'get', 'test-results', 'tests', '--path', path)
          raise "Failed to execute xcresulttool command - #{stderr}" unless status.success?
          JSON.parse(stdout)
        end
      end
    end
  end
end
