require_relative 'helper'
require_relative 'test_case_attributes'
require_relative 'repetition'

module Trainer
  module XCResult
    # Represents a test case, including its retries (aka repetitions)
    class TestCase
      include TestCaseAttributes

      attr_reader :name
      attr_reader :identifier
      attr_reader :duration
      attr_reader :result
      attr_reader :classname
      attr_reader :argument
      # @return [Array<Repetition>] Array of retry attempts for this test case, **including the initial attempt**
      # This will be `nil` if the test case was not run multiple times, but will contain all repetitions if it was run more than once.
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

          failure_messages = if retries.empty?
                               extract_failure_messages(node_for_attributes)
                             else
                               retries.flat_map(&:failure_messages)
                             end

          source_references = if retries.empty?
                                extract_source_references(node_for_attributes)
                              else
                                retries.flat_map(&:source_references)
                              end

          attachments = if retries.empty?
                          extract_attachments(node_for_attributes)
                        else
                          retries.flat_map(&:attachments)
                        end

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
            name: if @argument.nil?
                    @name
                  else
                    @name.match?(/(\(.*\))/) ? @name.gsub(/(\(.*\))/, "(#{@argument})") : "#{@name} (#{@argument})"
                  end,
            classname: @classname,
            time: (run || self).duration.to_s).tap do |testcase|
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
          @retries.count(&:failed?)
        elsif failed?
          1
        else
          0
        end
      end

      def self.extract_classname(node)
        return nil if node['nodeIdentifier'].nil?

        parts = node['nodeIdentifier'].split('/')
        parts[0...-1].join('.')
      end
      private_class_method :extract_classname

      private

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
  end
end
