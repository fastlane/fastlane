require 'shellwords'
require 'json'
require 'open3'

module Trainer
  module XCResult
    # Model xcresulttool JSON output for Xcode16+ version of xcresulttool
    # See JSON schema from `xcrun xcresulttool get test-results tests --help`

    class TestCase
      attr_reader :name
      attr_reader :identifier
      attr_reader :duration
      attr_reader :result
      attr_reader :test_group
      attr_reader :arguments
      attr_reader :repetitions
      attr_reader :failure_messages
      attr_reader :source_references
      attr_reader :attachments
      attr_reader :tags

      def initialize(node)
        @name = node['name']
        @identifier = node['nodeIdentifier']
        @duration = parse_duration(node['duration'])
        @result = node['result']
        @test_group = extract_test_group(node)
        @arguments = extract_arguments(node)
        @repetitions = extract_repetitions(node)
        @failure_messages = extract_failure_messages(node)
        @source_references = extract_source_references(node)
        @attachments = extract_attachments(node)
        @tags = node['tags'] || []
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

      private

      def parse_duration(duration_str)
        return 0.0 if duration_str.nil?
        
        # Handle comma-separated duration (Xcode 16 format)
        duration_str = duration_str.gsub(',', '.')
        
        # Remove 's' suffix and convert to float
        duration_str.chomp('s').to_f
      end

      def extract_test_group(node)
        # Extract test group from identifier if possible
        return '' if @identifier.nil?
        
        # Split identifier and take all parts except the last (test name)
        parts = @identifier.split('/')
        parts[0...-1].join('/')
      end

      def extract_arguments(node)
        node['children']
          &.select { |child| child['nodeType'] == 'Arguments' }
          &.map { |arg| arg['name'] } || []
      end

      def extract_repetitions(node)
        node['children']
          &.select { |child| ['Repetition', 'Test Case Run'].include?(child['nodeType']) }
          &.map do |rep|
            {
              name: rep['name'],
              duration: parse_duration(rep['duration']),
              result: rep['result']
            }
          end || []
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

    class TestSuite
      attr_reader :name
      attr_reader :identifier
      attr_reader :type
      attr_reader :duration
      attr_reader :result
      attr_reader :test_cases
      attr_reader :sub_suites
      attr_reader :tags
      attr_reader :configuration
      attr_reader :device

      def initialize(node, configurations = [], devices = [])
        @name = node['name']
        @identifier = node['nodeIdentifier']
        @type = node['nodeType']
        @duration = parse_duration(node['duration'])
        @result = node['result']
        @tags = node['tags'] || []

        # Extract test cases and sub-suites
        @test_cases = []
        @sub_suites = []
        process_children(node['children'] || [])

        # Find associated configuration and device
        @configuration = configurations.find { |config| config['configurationName'] == @name }
        @device = devices.first  # For now, return the first device
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

      private

      def parse_duration(duration_str)
        return 0.0 if duration_str.nil?
        
        # Handle comma-separated duration (Xcode 16 format)
        duration_str = duration_str.gsub(',', '.')
        
        # Remove 's' suffix and convert to float
        duration_str.chomp('s').to_f
      end

      def process_children(children)
        children.each do |child|
          case child['nodeType']
          when 'Test Case'
            @test_cases << TestCase.new(child)
          when 'Test Suite', 'Unit test bundle', 'UI test bundle'
            @sub_suites << TestSuite.new(child)
          end
        end
      end
    end

    module Parser
      class << self
        # Since Xcode 16b3, xcresulttool has marked `get <object> --format json` as deprecated/legacy,
        # and replaced it with `xcrun xcresulttool get test-results tests` instead.
        def supports_xcode16_xcresulttool?
          # e.g. DEVELOPER_DIR=/Applications/Xcode_16_beta_3.app
          # xcresulttool version 23021, format version 3.53 (current)
          match = `xcrun xcresulttool version`.match(/xcresulttool version (?<version>[\d.]+)/)
          version = match[:version]

          Gem::Version.new(version) >= Gem::Version.new(23_021)
        end

        def parse_xcresult(path)
          json = xcresult_to_json(path)
          
          # Extract configurations and devices
          configurations = json['testPlanConfigurations'] || []
          devices = json['devices'] || []

          # Find the test plan node (root of test results)
          test_plan_node = json['testNodes']&.find { |node| node['nodeType'] == 'Test Plan' }
          
          return [] if test_plan_node.nil?

          # Convert test plan node's children (test bundles) to TestSuite objects
          test_plan_node['children']&.map do |test_bundle|
            TestSuite.new(test_bundle, configurations, devices)
          end || []
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
