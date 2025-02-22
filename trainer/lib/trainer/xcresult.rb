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
      attr_reader :classname
      attr_reader :argument
      attr_reader :repetition
      attr_reader :failure_messages
      attr_reader :source_references
      attr_reader :attachments
      attr_reader :tags

      def self.from_node(node:, xcpretty_naming:)
        # If there are arguments or repetitions, generate multiple test cases
        test_cases = []

        # Handle arguments
        argument_nodes = node['children']&.select { |child| child['nodeType'] == 'Arguments' } || []
        argument_nodes = [nil] if argument_nodes.empty?

        # Handle repetitions
        repetition_nodes = node['children']&.select { |child| ['Repetition', 'Test Case Run'].include?(child['nodeType']) } || []
        repetition_nodes = [nil] if repetition_nodes.empty?

        # Generate test cases for each combination of argument and repetition
        argument_nodes.each do |arg_node|
          repetition_nodes.each do |rep_node|
            modified_node = node.dup
            
            # Add argument information if present
            if arg_node
              modified_node['argument'] = arg_node['name']
            end

            # Add repetition information if present
            if rep_node
              # Only store the name of the repetition
              modified_node['repetition'] = rep_node['name']
              
              # Override result if repetition has a different result
              modified_node['result'] = rep_node['result'] if rep_node['result'] != node['result']
              
              # Override duration with repetition's duration if present
              modified_node['duration'] = rep_node['duration'] if rep_node['duration']
            end

            test_cases << new(node: modified_node, xcpretty_naming: xcpretty_naming)
          end
        end

        test_cases
      end

      def initialize(node:, xcpretty_naming:)
        @name = node['name']
        @identifier = node['nodeIdentifier']
        @duration = parse_duration(node['duration'] || node.dig('repetition', 'duration'))
        @result = node['result']
        @classname = extract_classname(node, xcpretty_naming: xcpretty_naming)
        @argument = node['argument']
        @repetition = node['repetition']
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
        testcase.attributes['classname'] = @classname
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
        if @argument || @repetition || @source_references.any? || @attachments.any? || @tags.any?
          properties = REXML::Element.new('properties')
          
          # Add argument as property
          if @argument
            prop = REXML::Element.new('property')
            prop.attributes['name'] = "argument"
            prop.attributes['value'] = @argument
            properties.add_element(prop)
          end

          # Add repetition as property
          if @repetition
            prop = REXML::Element.new('property')
            prop.attributes['name'] = "repetition"
            prop.attributes['value'] = @repetition
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

      def extract_classname(node, xcpretty_naming:)
        # Extract test group from identifier if possible
        return '' if @identifier.nil?
        
        # Split identifier and take all parts except the last (test name)
        parts = @identifier.split('/')
        parts[0...-1].join(xcpretty_naming ? '.' : '/')
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
      attr_reader :result
      attr_reader :test_cases
      attr_reader :sub_suites
      attr_reader :tags

      def initialize(node:, xcpretty_naming: false)
        @name = node['name']
        @identifier = node['nodeIdentifier']
        @type = node['nodeType']
        @result = node['result']
        @tags = node['tags'] || []

        # Extract test cases and sub-suites
        @test_cases = []
        @sub_suites = []
        process_children(node['children'] || [], xcpretty_naming: xcpretty_naming)
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
        @duration ||= @test_cases.sum { |tc| tc.duration } + @sub_suites.sum { |sub_suite| sub_suite.duration }
      end

      def test_cases_count
        @test_cases_count ||= @test_cases.count + @sub_suites.sum { |sub_suite| sub_suite.test_cases_count }
      end

      def failures_count
        @failures_count ||= @test_cases.count { |tc| tc.failed? } + @sub_suites.sum { |sub_suite| sub_suite.failures_count }
      end

      def skipped_count
        @skipped_count ||= @test_cases.count { |tc| tc.skipped? } + @sub_suites.sum { |sub_suite| sub_suite.skipped_count }
      end

      def to_hash
        {
          number_of_tests: test_cases_count,
          number_of_failures: failures_count,
          number_of_tests_excluding_retries: test_cases_count, # TODO: Implement this
          number_of_failures_excluding_retries: failures_count, # TODO: Implement this
          number_of_retries: 0, # TODO: Implement this
          number_of_skipped: skipped_count
        }
      end

      def to_xml
        testsuite = REXML::Element.new('testsuite')
        testsuite.attributes['name'] = @name
        testsuite.attributes['time'] = duration.to_s

        # Add test cases
        @test_cases.each do |test_case|
          testsuite.add_element(test_case.to_xml)
        end

        # Add sub-suites
        @sub_suites.each do |sub_suite|
          testsuite.add_element(sub_suite.to_xml)
        end

        # Add summary attributes
        testsuite.attributes['tests'] = test_cases_count.to_s
        testsuite.attributes['failures'] = failures_count.to_s
        testsuite.attributes['skipped'] = skipped_count.to_s  

        testsuite
      end

      private

      def process_children(children, xcpretty_naming:)
        children.each do |child|
          case child['nodeType']
          when 'Test Case'
            # Use from_node to generate multiple test cases if needed
            @test_cases.concat(TestCase.from_node(node: child, xcpretty_naming: xcpretty_naming))
          when 'Test Suite', 'Unit test bundle', 'UI test bundle'
            @sub_suites << TestSuite.new(node: child, xcpretty_naming: xcpretty_naming)
          end
        end
      end
    end

    class TestPlan
      attr_reader :test_suites, :name, :configurations, :devices

      def initialize(test_suites:, configurations: [], devices: [])
        @test_suites = test_suites
        @configurations = configurations
        @devices = devices
      end

      include Enumerable
      def each(&block)
        test_suites.map(&:to_hash).each(&block)
      end

      def to_xml
        # Create the root testsuites element
        testsuites = REXML::Element.new('testsuites')
        
        # Add each test suite to the root
        test_suites.each do |suite|
          testsuites.add_element(suite.to_xml)
        end

        # Calculate total summary
        testsuites.attributes['tests'] = test_suites.sum { |suite| suite.test_cases_count }.to_s
        testsuites.attributes['failures'] = test_suites.sum { |suite| suite.failures_count }.to_s
        testsuites.attributes['skipped'] = test_suites.sum { |suite| suite.skipped_count }.to_s
        testsuites.attributes['time'] = test_suites.sum { |suite| suite.duration }.to_s

        # Convert to XML string with prologue
        doc = REXML::Document.new
        doc << REXML::XMLDecl.new('1.0', 'UTF-8')

        unless @configurations.empty? && @devices.empty?
          # Add properties for configuration and device
          properties = REXML::Element.new('properties')
        
          @configurations.each do |config|
            config_prop = REXML::Element.new('property')
            config_prop.attributes['name'] = 'testPlanConfiguration'
            config_prop.attributes['value'] = config['configurationName']
            properties.add_element(config_prop)
          end
  
          @devices.each do |device|
            device_prop = REXML::Element.new('property')
            device_prop.attributes['name'] = 'device'
            device_prop.attributes['value'] = "#{device.fetch('modelName', 'Unknown Device')} (#{device.fetch('osVersion', 'Unknown OS Version')})"
            properties.add_element(device_prop)
          end
        
          testsuites.add_element(properties) if properties.elements.any?
        end
        
        doc.add(testsuites)

        formatter = REXML::Formatters::Pretty.new
        output = String.new
        formatter.write(doc, output)
        output
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

        def parse_xcresult(path:, output_remove_retry_attempts: false, xcpretty_naming: false)
          # TODO: Remove retry attempts if output_remove_retry_attempts is true
          json = xcresult_to_json(path)
          
          # Extract configurations and devices
          configurations = json['testPlanConfigurations'] || []
          devices = json['devices'] || []

          # Find the test plan node (root of test results)
          test_plan_node = json['testNodes']&.find { |node| node['nodeType'] == 'Test Plan' }
          return TestPlan.new(test_suites: []) if test_plan_node.nil?

          # Convert test plan node's children (test bundles) to TestSuite objects
          test_suites = test_plan_node['children']&.map do |test_bundle|
            TestSuite.new(node: test_bundle, xcpretty_naming: xcpretty_naming)
          end || []

          TestPlan.new(test_suites: test_suites, configurations: configurations, devices: devices)
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
