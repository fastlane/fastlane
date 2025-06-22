require_relative 'test_case'

module Trainer
  module XCResult
    # Represents a test suite, including its test cases and sub-suites
    class TestSuite
      attr_reader :name
      attr_reader :identifier
      attr_reader :type
      attr_reader :result
      attr_reader :test_cases
      attr_reader :sub_suites
      attr_reader :tags

      def initialize(name:, identifier:, type:, result:, tags: [], test_cases: [], sub_suites: [])
        @name = name
        @identifier = identifier
        @type = type
        @result = result
        @tags = tags
        @test_cases = test_cases
        @sub_suites = sub_suites
      end

      def self.from_json(node:)
        # Create initial TestSuite with basic attributes
        test_suite = new(
          name: node['name'],
          identifier: node['nodeIdentifier'],
          type: node['nodeType'],
          result: node['result'],
          tags: node['tags'] || []
        )

        # Process children to populate test_cases and sub_suites
        test_suite.process_children(node['children'] || [])

        test_suite
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

      def duration
        @duration ||= @test_cases.sum(&:duration) + @sub_suites.sum(&:duration)
      end

      def test_cases_count
        @test_cases_count ||= @test_cases.count + @sub_suites.sum(&:test_cases_count)
      end

      def failures_count
        @failures_count ||= @test_cases.count(&:failed?) + @sub_suites.sum(&:failures_count)
      end

      def skipped_count
        @skipped_count ||= @test_cases.count(&:skipped?) + @sub_suites.sum(&:skipped_count)
      end

      def total_tests_count
        @test_cases.sum(&:total_tests_count) +
          @sub_suites.sum(&:total_tests_count)
      end

      def total_failures_count
        @test_cases.sum(&:total_failures_count) +
          @sub_suites.sum(&:total_failures_count)
      end

      def total_retries_count
        @test_cases.sum(&:retries_count) +
          @sub_suites.sum(&:total_retries_count)
      end

      # Hash representation used by TestParser to collect test results
      def to_hash
        {
          number_of_tests: total_tests_count,
          number_of_failures: total_failures_count,
          number_of_tests_excluding_retries: test_cases_count,
          number_of_failures_excluding_retries: failures_count,
          number_of_retries: total_retries_count,
          number_of_skipped: skipped_count
        }
      end

      # Generates a JUnit-compatible XML representation of the test suite
      # See https://github.com/testmoapp/junitxml/
      def to_xml(output_remove_retry_attempts: false)
        testsuite = Helper.create_xml_element('testsuite',
          name: @name,
          time: duration.to_s,
          tests: test_cases_count.to_s,
          failures: failures_count.to_s,
          skipped: skipped_count.to_s)

        # Add test cases
        @test_cases.each do |test_case|
          runs = test_case.to_xml_nodes
          runs = runs.last(1) if output_remove_retry_attempts
          runs.each { |node| testsuite.add_element(node) }
        end

        # Add sub-suites
        @sub_suites.each do |sub_suite|
          testsuite.add_element(sub_suite.to_xml(output_remove_retry_attempts: output_remove_retry_attempts))
        end

        testsuite
      end

      def process_children(children)
        children.each do |child|
          case child['nodeType']
          when 'Test Case'
            # Use from_json to generate multiple test cases if needed
            @test_cases.concat(TestCase.from_json(node: child))
          when 'Test Suite', 'Unit test bundle', 'UI test bundle'
            @sub_suites << TestSuite.from_json(node: child)
          end
        end
      end
    end
  end
end
