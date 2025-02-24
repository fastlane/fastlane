require 'shellwords'
require 'json'
require 'open3'
require 'rexml/document'

module Trainer
  # Model xcresulttool JSON output for Xcode16+ version of xcresulttool
  # See JSON schema from `xcrun xcresulttool get test-results tests --help`
  module XCResult
    # Helper class for XML and node operations
    class Helper
      # Creates an XML element with the given name and attributes
      #
      # @param name [String] The name of the XML element
      # @param attributes [Hash] A hash of attributes to add to the element
      # @return [REXML::Element] The created XML element
      def self.create_xml_element(name, **attributes)
        element = REXML::Element.new(name)
        attributes.compact.each { |key, value| element.attributes[key.to_s] = value.to_s }
        element
      end

      # Find children of a node by specified node types
      #
      # @param node [Hash, nil] The JSON node to search within
      # @param node_types [Array<String>] The node types to filter by
      # @return [Array<Hash>] Array of child nodes matching the specified types
      def self.find_json_children(node, *node_types)
        return [] if node.nil? || node['children'].nil?
        
        node['children'].select { |child| node_types.include?(child['nodeType']) }
      end
    end

    # Mixin for shared test case and repetition attributes
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

    class TestCase
      include TestCaseAttributes

      attr_reader :name
      attr_reader :identifier
      attr_reader :duration
      attr_reader :result
      attr_reader :classname
      attr_reader :argument
      attr_reader :retries
      attr_reader :failure_messages
      attr_reader :source_references
      attr_reader :attachments
      attr_reader :tags

      def initialize(
        name:, identifier:, duration:, result:, classname:, argument: nil, tags: [], retries: nil,
        failure_messages: [], source_references: [], attachments: []
      )
        @name = name
        @identifier = identifier
        @duration = duration
        @result = result
        @classname = classname
        @argument = argument
        @tags = tags
        @retries = retries
        @failure_messages = failure_messages
        @source_references = source_references
        @attachments = attachments
      end

      def self.from_json(node:)
        # Handle test case arguments
        argument_nodes = Helper.find_json_children(node, 'Arguments')
        argument_nodes = [nil] if argument_nodes.empty?

        # Generate test cases for each argument
        argument_nodes.map do |arg_node|
          # For repetition nodes, failure messages, source refs, attachments and result attributes,
          # Search them as children of the argument child node if present, of the test case node otherwise.
          node_for_attributes = arg_node || node

          retries = Helper.find_json_children(node_for_attributes, 'Repetition', 'Test Case Run')
                         &.map { |rep_node| Repetition.from_json(node: rep_node) } || []

          failure_messages = retries.empty? ? 
            extract_failure_messages(node_for_attributes) : 
            retries.flat_map(&:failure_messages)
          
          source_references = retries.empty? ? 
            extract_source_references(node_for_attributes) : 
            retries.flat_map(&:source_references)

          attachments = retries.empty? ? 
            extract_attachments(node_for_attributes) : 
            retries.flat_map(&:attachments)

          new(
            name: node['name'],
            identifier: node['nodeIdentifier'],
            duration: parse_duration(node['duration']),
            result: node_for_attributes['result'],
            classname: extract_classname(node),
            argument: arg_node&.[]('name'), # Only set if there is an argument
            tags: node['tags'] || [],
            retries: retries,
            failure_messages: failure_messages,
            source_references: source_references,
            attachments: attachments
          )
        end
      end

      # Generates XML nodes for the test case
      #
      # @return [Array<REXML::Element>] An array of XML <testcase> elements
      #
      # - If no retries, the array contains a single <testcase> element
      # - If retries, the array contains one <testcase> element per retry
      def to_xml_nodes
        runs = @retries.nil? || @retries.empty? ? [nil] : @retries
        
        runs.map do |run|
          Helper.create_xml_element('testcase',
            name: @argument.nil? ? @name : @name.match?(/(\(.*\))/) ? @name.gsub(/(\(.*\))/, "(#{@argument})") : "#{@name} (#{@argument})",
            classname: @classname,
            time: (run || self).duration.to_s
          ).tap do |testcase|
            add_xml_result_elements(testcase, run || self)
            add_properties_to_xml(testcase, repetition_name: run&.name)
          end
        end
      end

      def retries_count
        @retries&.count || 0
      end

      def total_tests_count
        retries_count > 0 ? retries_count : 1
      end

      def total_failures_count
        if retries_count > 0
          @retries.count { |retry_run| retry_run.failed? }
        elsif failed?
          1
        else
          0
        end
      end

      private

      def self.extract_classname(node)
        return nil if node['nodeIdentifier'].nil?
        
        parts = node['nodeIdentifier'].split('/')
        parts[0...-1].join('.')
      end

      # Adds <properties> element to the XML <testcase> element
      #
      # @param testcase [REXML::Element] The XML testcase element to add properties to
      # @param repetition_name [String, nil] Name of the retry attempt, if this is a retry
      #
      # Properties added:
      # - if argument is present:
      #   - `testname`: Raw test name (as in such case, <testcase name="…"> would contain a mix of the test name and the argument)
      #   - `argument`: Test argument value
      # - `repetitionN`: Name of the retry attempt if present
      # - `source_referenceN`: Source code references (file/line) for failures
      # - `attachmentN`: Test attachments like screenshots
      # - `tagN`: Test tags/categories
      #
      # <properties> element is only added to the XML if at least one property exists
      def add_properties_to_xml(testcase, repetition_name: nil)
        properties = Helper.create_xml_element('properties')
        
        # Add argument as property
        if @argument
          name_prop = Helper.create_xml_element('property', name: "testname", value: @name)
          properties.add_element(name_prop)
          prop = Helper.create_xml_element('property', name: "argument", value: @argument)
          properties.add_element(prop)
        end

        # Add repetition as property
        if repetition_name
          prop = Helper.create_xml_element('property', name: "repetition", value: repetition_name)
          properties.add_element(prop)
        end

        # Add source references as properties
        (@source_references || []).each_with_index do |ref, index|
          prop = Helper.create_xml_element('property', name: "source_reference#{index + 1}", value: ref)
          properties.add_element(prop)
        end

        # Add attachments as properties
        (@attachments || []).each_with_index do |attachment, index|
          prop = Helper.create_xml_element('property', name: "attachment#{index + 1}", value: attachment)
          properties.add_element(prop)
        end

        # Add tags as properties
        (@tags || []).sort.each_with_index do |tag, index|
          prop = Helper.create_xml_element('property', name: "tag#{index + 1}", value: tag)
          properties.add_element(prop)
        end

        # Only add properties to testcase if it has child elements
        testcase.add_element(properties) if properties.elements.any?
      end

      # Adds <failure> and <skipped> elements to the XML <testcase> element based on test status
      #
      # @param testcase [REXML::Element] The XML testcase element to add result elements to
      # @param test_obj [Repetition, TestCase] Object representing the test result
      #   This can be either a Repetition object or the TestCase itself.
      #   Must respond to the following methods:
      #   - failed? [Boolean]: Indicates if the test failed
      #   - skipped? [Boolean]: Indicates if the test was skipped
      #   - failure_messages [Array<String>, nil]: List of failure messages (optional)
      #
      # Adds:
      # - <failure> elements with messages for failed tests
      # - <skipped> element for skipped tests
      # - No elements added for passed tests
      def add_xml_result_elements(testcase, test_obj)
        if test_obj.failed?
          (test_obj.failure_messages&.any? ? test_obj.failure_messages : [nil]).each do |msg|
            testcase.add_element(Helper.create_xml_element('failure', message: msg))
          end
        elsif test_obj.skipped?
          testcase.add_element(Helper.create_xml_element('skipped', message: test_obj.failure_messages&.first))
        end
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
          skipped: skipped_count.to_s
        )

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

    # Represents a collection of test suites + the configuration, and device used to run them
    class TestPlan
      attr_reader :test_suites, :name, :configurations, :devices
      attr_accessor :output_remove_retry_attempts

      def initialize(test_suites:, configurations: [], devices: [], output_remove_retry_attempts: false)
        @test_suites = test_suites
        @configurations = configurations
        @devices = devices
        @output_remove_retry_attempts = output_remove_retry_attempts
      end

      def self.from_json(json:)
        # Extract configurations and devices
        configurations = json['testPlanConfigurations'] || []
        devices = json['devices'] || []

        # Find the test plan node (root of test results)
        test_plan_node = json['testNodes']&.find { |node| node['nodeType'] == 'Test Plan' }
        return new(test_suites: []) if test_plan_node.nil?

        # Convert test plan node's children (test bundles) to TestSuite objects
        test_suites = test_plan_node['children']&.map do |test_bundle|
          TestSuite.from_json(
            node: test_bundle
          )
        end || []

        new(
          test_suites: test_suites, 
          configurations: configurations, 
          devices: devices
        )
      end

      # Allows iteration over test suites. Used by TestParser to collect test results
      include Enumerable
      def each(&block)
        test_suites.map(&:to_hash).each(&block)
      end

      # Generates a JUnit-compatible XML representation of the test plan
      # See https://github.com/testmoapp/junitxml/
      def to_xml
        # Create the root testsuites element with calculated summary attributes
        testsuites = Helper.create_xml_element('testsuites',
          tests: test_suites.sum(&:test_cases_count).to_s,
          failures: test_suites.sum(&:failures_count).to_s,
          skipped: test_suites.sum(&:skipped_count).to_s,
          time: test_suites.sum(&:duration).to_s
        )
        
        # Add each test suite to the root
        test_suites.each do |suite|
          testsuites.add_element(suite.to_xml(output_remove_retry_attempts: output_remove_retry_attempts))
        end

        # Convert to XML string with prologue
        doc = REXML::Document.new
        doc << REXML::XMLDecl.new('1.0', 'UTF-8')

        # Add properties for configuration and device
        properties = Helper.create_xml_element('properties')
      
        @configurations.each do |config|
          config_prop = Helper.create_xml_element('property', name: 'Configuration', value: config['configurationName'])
          properties.add_element(config_prop)
        end

        @devices.each do |device|
          device_prop = Helper.create_xml_element('property', name: 'device', value: "#{device.fetch('modelName', 'Unknown Device')} (#{device.fetch('osVersion', 'Unknown OS Version')})")
          properties.add_element(device_prop)
        end
      
        testsuites.add_element(properties) if properties.elements.any?
        
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
