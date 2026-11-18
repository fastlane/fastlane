module Trainer
  module XCResult
    # Mixin for shared attributes between TestCase and Repetition
    module TestCaseAttributes
      def self.included(base)
        base.extend(ClassMethods)
      end

      def passed?
        @result == 'Passed'
      end

      def failed?
        @result == 'Failed'
      end

      def skipped?
        @result == 'Skipped'
      end

      module ClassMethods
        def parse_duration(duration_str)
          return 0.0 if duration_str.nil?

          # Handle comma-separated duration, and remove 's' suffix
          duration_str.gsub(',', '.').chomp('s').to_f
        end

        def extract_failure_messages(node)
          node['children']
            &.select { |child| child['nodeType'] == 'Failure Message' }
            &.map { |msg| msg['name'] } || []
        end

        def extract_source_references(node)
          node['children']
            &.select { |child| child['nodeType'] == 'Source Code Reference' }
            &.map { |ref| ref['name'] } || []
        end

        def extract_attachments(node)
          node['children']
            &.select { |child| child['nodeType'] == 'Attachment' }
            &.map { |attachment| attachment['name'] } || []
        end
      end
    end
  end
end
