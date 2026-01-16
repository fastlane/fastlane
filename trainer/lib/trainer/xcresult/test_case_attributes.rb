require 'fastlane_core/helper'

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
        def extract_duration(node)
          if FastlaneCore::Helper.xcode_at_least?('16.3')
            node['durationInSeconds'] || 0.0
          else
            duration_str = node['duration']

            return 0.0 if duration_str.nil?

            # Handle different duration formats: "1m 5s", "22s", "0,011s"
            if duration_str.include?('m')
              # Parse format like "1m 5s"
              parts = duration_str.split
              minutes = parts.find { |p| p.include?('m') }&.gsub('m', '').to_f
              seconds = parts.find { |p| p.include?('s') }&.gsub(',', '.')&.chomp('s').to_f
              minutes * 60 + seconds
            else
              # Parse format like "22s", "0,011s"
              duration_str.gsub(',', '.').chomp('s').to_f
            end
          end
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
