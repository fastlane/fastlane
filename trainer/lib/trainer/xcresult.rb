require 'shellwords'
require 'json'
require 'open3'
require 'rexml/document'

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

      def initialize(node:)
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

      def to_xml
        testcase = REXML::Element.new('testcase')
        testcase.attributes['name'] = @name
        testcase.attributes['classname'] = @test_group
        testcase.attributes['time'] = @duration.to_s

        # Handle test result
        if failed?
          failure = REXML::Element.new('failure')
          failure.attributes['message'] = @failure_messages.first if @failure_messages.any?
          testcase.add_element(failure)
        elsif skipped?
          testcase.add_element(REXML::Element.new('skipped'))
        end

        # Add properties if available
        if @arguments.any? || @repetitions.any? || @source_references.any? || @attachments.any? || @tags.any?
          properties = REXML::Element.new('properties')
          
          # Add arguments as properties
          @arguments.each_with_index do |arg, index|
            prop = REXML::Element.new('property')
            prop.attributes['name'] = "argument#{index + 1}"
            prop.attributes['value'] = arg
            properties.add_element(prop)
          end

          # Add repetitions as properties
          @repetitions.each_with_index do |rep, index|
            prop = REXML::Element.new('property')
            prop.attributes['name'] = "repetition#{index + 1}"
            prop.attributes['value'] = "#{rep[:name]} (#{rep[:result]})"
            properties.add_element(prop)
          end

          # Add source references as properties
          @source_references.each_with_index do |ref, index|
            prop = REXML::Element.new('property')
            prop.attributes['name'] = "source_reference#{index + 1}"
            prop.attributes['value'] = ref
            properties.add_element(prop)
          end

          # Add attachments as properties
          @attachments.each_with_index do |attachment, index|
            prop = REXML::Element.new('property')
            prop.attributes['name'] = "attachment#{index + 1}"
            prop.attributes['value'] = attachment
            properties.add_element(prop)
          end

          # Add tags as properties
          @tags.each_with_index do |tag, index|
            prop = REXML::Element.new('property')
            prop.attributes['name'] = "tag#{index + 1}"
            prop.attributes['value'] = tag
            properties.add_element(prop)
          end

          testcase.add_element(properties)
        end

        testcase
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

      def initialize(node:, configurations: [], devices: [])
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

      def to_xml
        testsuite = REXML::Element.new('testsuite')
        testsuite.attributes['name'] = @name
        testsuite.attributes['time'] = @duration.to_s

        # Add test cases
        @test_cases.each do |test_case|
          testsuite.add_element(test_case.to_xml)
        end

        # Add sub-suites
        @sub_suites.each do |sub_suite|
          testsuite.add_element(sub_suite.to_xml)
        end

        # Add properties for configuration and device
        properties = REXML::Element.new('properties')
        
        if @configuration
          config_prop = REXML::Element.new('property')
          config_prop.attributes['name'] = 'configuration'
          config_prop.attributes['value'] = @configuration['configurationName']
          properties.add_element(config_prop)
        end

        if @device
          device_prop = REXML::Element.new('property')
          device_prop.attributes['name'] = 'device'
          device_prop.attributes['value'] = @device['name'] || 'Unknown Device'
          properties.add_element(device_prop)
        end

        testsuite.add_element(properties) if properties.elements.any?

        # Add summary attributes
        testsuite.attributes['tests'] = @test_cases.count.to_s
        testsuite.attributes['failures'] = @test_cases.count { |tc| tc.failed? }.to_s
        testsuite.attributes['skipped'] = @test_cases.count { |tc| tc.skipped? }.to_s

        testsuite
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
            @test_cases << TestCase.new(node: child)
          when 'Test Suite', 'Unit test bundle', 'UI test bundle'
            @sub_suites << TestSuite.new(node: child)
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

        class TestPlan
          attr_reader :test_suites, :name

          def initialize(test_suites:, name: 'XCResult Test Run')
            @test_suites = test_suites
            @name = name
          end

          def to_xml
            # Create the root testsuites element
            testsuites = REXML::Element.new('testsuites')
            testsuites.attributes['name'] = name
            
            # Add each test suite to the root
            test_suites.each do |suite|
              testsuites.add_element(suite.to_xml)
            end

            # Calculate total summary
            testsuites.attributes['tests'] = test_suites.sum { |suite| suite.test_cases.count }.to_s
            testsuites.attributes['failures'] = test_suites.sum { |suite| suite.test_cases.count { |tc| tc.failed? } }.to_s
            testsuites.attributes['skipped'] = test_suites.sum { |suite| suite.test_cases.count { |tc| tc.skipped? } }.to_s
            testsuites.attributes['time'] = test_suites.sum { |suite| suite.duration }.to_s

            # Convert to XML string
            doc = REXML::Document.new
            doc.add(testsuites)
            
            formatter = REXML::Formatters::Pretty.new
            output = String.new
            formatter.write(doc, output)
            output
          end
        end

        def parse_xcresult(path:)
          json = xcresult_to_json(path)
          
          # Extract configurations and devices
          configurations = json['testPlanConfigurations'] || []
          devices = json['devices'] || []

          # Find the test plan node (root of test results)
          test_plan_node = json['testNodes']&.find { |node| node['nodeType'] == 'Test Plan' }
          
          return TestPlan.new(test_suites: []) if test_plan_node.nil?

          # Convert test plan node's children (test bundles) to TestSuite objects
          test_suites = test_plan_node['children']&.map do |test_bundle|
            TestSuite.new(node: test_bundle, configurations: configurations, devices: devices)
          end || []

          TestPlan.new(test_suites: test_suites)
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
