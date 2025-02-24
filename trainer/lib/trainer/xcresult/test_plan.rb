require_relative 'test_suite'

module Trainer
  module XCResult
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
          time: test_suites.sum(&:duration).to_s)

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
  end
end
