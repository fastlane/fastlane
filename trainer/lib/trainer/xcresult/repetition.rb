require_relative 'test_case_attributes'

module Trainer
  module XCResult
    # Represents retries of a test case, including the original run
    # e.g. a test case that ran 3 times in total will be represented by 3 Repetition instances in the `xcresulttool` JSON output,
    # one for the original run and one for the 2 retries.
    class Repetition
      include TestCaseAttributes

      attr_reader :name
      attr_reader :duration
      attr_reader :result
      attr_reader :failure_messages
      attr_reader :source_references
      attr_reader :attachments

      def initialize(name:, duration:, result:, failure_messages: [], source_references: [], attachments: [])
        @name = name
        @duration = duration
        @result = result
        @failure_messages = failure_messages
        @source_references = source_references
        @attachments = attachments
      end

      def self.from_json(node:)
        new(
          name: node['name'],
          duration: parse_duration(node['duration']),
          result: node['result'],
          failure_messages: extract_failure_messages(node),
          source_references: extract_source_references(node),
          attachments: extract_attachments(node)
        )
      end
    end
  end
end
