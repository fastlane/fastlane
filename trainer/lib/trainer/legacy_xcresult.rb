require 'open3'

require_relative 'xcresult/helper'

module Trainer
  module LegacyXCResult
    # Model attributes and relationships taken from running the following command:
    # xcrun xcresulttool formatDescription --legacy

    class AbstractObject
      attr_accessor :type
      def initialize(data)
        self.type = data["_type"]["_name"]
      end

      def fetch_value(data, key)
        return (data[key] || {})["_value"]
      end

      def fetch_values(data, key)
        return (data[key] || {})["_values"] || []
      end
    end

    # - ActionTestPlanRunSummaries
    #   * Kind: object
    #   * Properties:
    #     + summaries: [ActionTestPlanRunSummary]
    class ActionTestPlanRunSummaries < AbstractObject
      attr_accessor :summaries
      def initialize(data)
        self.summaries = fetch_values(data, "summaries").map do |summary_data|
          ActionTestPlanRunSummary.new(summary_data)
        end
        super
      end
    end

    # - ActionAbstractTestSummary
    #   * Kind: object
    #   * Properties:
    #     + name: String?
    class ActionAbstractTestSummary < AbstractObject
      attr_accessor :name
      def initialize(data)
        self.name = fetch_value(data, "name")
        super
      end
    end

    # - ActionTestPlanRunSummary
    #   * Supertype: ActionAbstractTestSummary
    #   * Kind: object
    #   * Properties:
    #     + testableSummaries: [ActionTestableSummary]
    class ActionTestPlanRunSummary < ActionAbstractTestSummary
      attr_accessor :testable_summaries
      def initialize(data)
        self.testable_summaries = fetch_values(data, "testableSummaries").map do |summary_data|
          ActionTestableSummary.new(summary_data)
        end
        super
      end
    end

    # - ActionTestableSummary
    #   * Supertype: ActionAbstractTestSummary
    #   * Kind: object
    #   * Properties:
    #     + projectRelativePath: String?
    #     + targetName: String?
    #     + testKind: String?
    #     + tests: [ActionTestSummaryIdentifiableObject]
    #     + diagnosticsDirectoryName: String?
    #     + failureSummaries: [ActionTestFailureSummary]
    #     + testLanguage: String?
    #     + testRegion: String?
    class ActionTestableSummary < ActionAbstractTestSummary
      attr_accessor :project_relative_path
      attr_accessor :target_name
      attr_accessor :test_kind
      attr_accessor :tests
      def initialize(data)
        self.project_relative_path = fetch_value(data, "projectRelativePath")
        self.target_name = fetch_value(data, "targetName")
        self.test_kind = fetch_value(data, "testKind")
        self.tests = fetch_values(data, "tests").map do |tests_data|
          ActionTestSummaryIdentifiableObject.create(tests_data, self)
        end
        super
      end

      def all_tests
        return tests.map(&:all_subtests).flatten
      end
    end

    # - ActionTestSummaryIdentifiableObject
    #   * Supertype: ActionAbstractTestSummary
    #   * Kind: object
    #   * Properties:
    #     + identifier: String?
    class ActionTestSummaryIdentifiableObject < ActionAbstractTestSummary
      attr_accessor :identifier
      attr_accessor :parent
      def initialize(data, parent)
        self.identifier = fetch_value(data, "identifier")
        self.parent = parent
        super(data)
      end

      def all_subtests
        raise "Not overridden"
      end

      def self.create(data, parent)
        type = data["_type"]["_name"]
        if type == "ActionTestSummaryGroup"
          return ActionTestSummaryGroup.new(data, parent)
        elsif type == "ActionTestMetadata"
          return ActionTestMetadata.new(data, parent)
        else
          raise "Unsupported type: #{type}"
        end
      end
    end

    # - ActionTestSummaryGroup
    #   * Supertype: ActionTestSummaryIdentifiableObject
    #   * Kind: object
    #   * Properties:
    #     + duration: Double
    #     + subtests: [ActionTestSummaryIdentifiableObject]
    class ActionTestSummaryGroup < ActionTestSummaryIdentifiableObject
      attr_accessor :duration
      attr_accessor :subtests
      def initialize(data, parent)
        self.duration = fetch_value(data, "duration").to_f
        self.subtests = fetch_values(data, "subtests").map do |subtests_data|
          ActionTestSummaryIdentifiableObject.create(subtests_data, self)
        end
        super(data, parent)
      end

      def all_subtests
        return subtests.map(&:all_subtests).flatten
      end
    end

    # - ActionTestMetadata
    #   * Supertype: ActionTestSummaryIdentifiableObject
    #   * Kind: object
    #   * Properties:
    #     + testStatus: String
    #     + duration: Double?
    #     + summaryRef: Reference?
    #     + performanceMetricsCount: Int
    #     + failureSummariesCount: Int
    #     + activitySummariesCount: Int
    class ActionTestMetadata < ActionTestSummaryIdentifiableObject
      attr_accessor :test_status
      attr_accessor :duration
      attr_accessor :performance_metrics_count
      attr_accessor :failure_summaries_count
      attr_accessor :activity_summaries_count
      def initialize(data, parent)
        self.test_status = fetch_value(data, "testStatus")
        self.duration = fetch_value(data, "duration").to_f
        self.performance_metrics_count = fetch_value(data, "performanceMetricsCount")
        self.failure_summaries_count = fetch_value(data, "failureSummariesCount")
        self.activity_summaries_count = fetch_value(data, "activitySummariesCount")
        super(data, parent)
      end

      def all_subtests
        return [self]
      end

      def find_failure(failures)
        sanitizer = proc { |name| name.gsub(/\W/, "_") }
        sanitized_identifier = sanitizer.call(self.identifier)
        if self.test_status == "Failure"
          # Tries to match failure on test case name
          # Example TestFailureIssueSummary:
          #   producingTarget: "TestThisDude"
          #   test_case_name: "TestThisDude.testFailureJosh2()" (when Swift)
          #     or "-[TestThisDudeTests testFailureJosh2]" (when Objective-C)
          # Example ActionTestMetadata
          #   identifier: "TestThisDude/testFailureJosh2()" (when Swift)
          #     or identifier: "TestThisDude/testFailureJosh2" (when Objective-C)

          found_failure = failures.find do |failure|
            # Sanitize both test case name and identifier in a consistent fashion, then replace all non-word
            # chars with underscore, and compare them
            sanitized_test_case_name = sanitizer.call(failure.test_case_name)
            sanitized_identifier == sanitized_test_case_name
          end
          return found_failure
        else
          return nil
        end
      end
    end

    # - ActionsInvocationRecord
    #   * Kind: object
    #   * Properties:
    #     + metadataRef: Reference?
    #     + metrics: ResultMetrics
    #     + issues: ResultIssueSummaries
    #     + actions: [ActionRecord]
    #     + archive: ArchiveInfo?
    class ActionsInvocationRecord < AbstractObject
      attr_accessor :actions
      attr_accessor :issues
      def initialize(data)
        self.actions = fetch_values(data, "actions").map do |action_data|
          ActionRecord.new(action_data)
        end
        self.issues = ResultIssueSummaries.new(data["issues"])
        super
      end
    end

    # - ActionRecord
    #   * Kind: object
    #   * Properties:
    #     + schemeCommandName: String
    #     + schemeTaskName: String
    #     + title: String?
    #     + startedTime: Date
    #     + endedTime: Date
    #     + runDestination: ActionRunDestinationRecord
    #     + buildResult: ActionResult
    #     + actionResult: ActionResult
    class ActionRecord < AbstractObject
      attr_accessor :scheme_command_name
      attr_accessor :scheme_task_name
      attr_accessor :title
      attr_accessor :build_result
      attr_accessor :action_result
      def initialize(data)
        self.scheme_command_name = fetch_value(data, "schemeCommandName")
        self.scheme_task_name = fetch_value(data, "schemeTaskName")
        self.title = fetch_value(data, "title")
        self.build_result = ActionResult.new(data["buildResult"])
        self.action_result = ActionResult.new(data["actionResult"])
        super
      end
    end

    # - ActionResult
    #   * Kind: object
    #   * Properties:
    #     + resultName: String
    #     + status: String
    #     + metrics: ResultMetrics
    #     + issues: ResultIssueSummaries
    #     + coverage: CodeCoverageInfo
    #     + timelineRef: Reference?
    #     + logRef: Reference?
    #     + testsRef: Reference?
    #     + diagnosticsRef: Reference?
    class ActionResult < AbstractObject
      attr_accessor :result_name
      attr_accessor :status
      attr_accessor :issues
      attr_accessor :timeline_ref
      attr_accessor :log_ref
      attr_accessor :tests_ref
      attr_accessor :diagnostics_ref
      def initialize(data)
        self.result_name = fetch_value(data, "resultName")
        self.status = fetch_value(data, "status")
        self.issues = ResultIssueSummaries.new(data["issues"])

        self.timeline_ref = Reference.new(data["timelineRef"]) if data["timelineRef"]
        self.log_ref = Reference.new(data["logRef"]) if data["logRef"]
        self.tests_ref = Reference.new(data["testsRef"]) if data["testsRef"]
        self.diagnostics_ref = Reference.new(data["diagnosticsRef"]) if data["diagnosticsRef"]
        super
      end
    end

    # - Reference
    #   * Kind: object
    #   * Properties:
    #     + id: String
    #     + targetType: TypeDefinition?
    class Reference < AbstractObject
      attr_accessor :id
      attr_accessor :target_type
      def initialize(data)
        self.id = fetch_value(data, "id")
        self.target_type = TypeDefinition.new(data["targetType"]) if data["targetType"]
        super
      end
    end

    # - TypeDefinition
    #   * Kind: object
    #   * Properties:
    #     + name: String
    #     + supertype: TypeDefinition?
    class TypeDefinition < AbstractObject
      attr_accessor :name
      attr_accessor :supertype
      def initialize(data)
        self.name = fetch_value(data, "name")
        self.supertype = TypeDefinition.new(data["supertype"]) if data["supertype"]
        super
      end
    end

    # - DocumentLocation
    #   * Kind: object
    #   * Properties:
    #     + url: String
    #     + concreteTypeName: String
    class DocumentLocation < AbstractObject
      attr_accessor :url
      attr_accessor :concrete_type_name
      def initialize(data)
        self.url = fetch_value(data, "url")
        self.concrete_type_name = data["concreteTypeName"]["_value"]
        super
      end
    end

    # - IssueSummary
    #   * Kind: object
    #   * Properties:
    #     + issueType: String
    #     + message: String
    #     + producingTarget: String?
    #     + documentLocationInCreatingWorkspace: DocumentLocation?
    class IssueSummary < AbstractObject
      attr_accessor :issue_type
      attr_accessor :message
      attr_accessor :producing_target
      attr_accessor :document_location_in_creating_workspace
      def initialize(data)
        self.issue_type = fetch_value(data, "issueType")
        self.message = fetch_value(data, "message")
        self.producing_target = fetch_value(data, "producingTarget")
        self.document_location_in_creating_workspace = DocumentLocation.new(data["documentLocationInCreatingWorkspace"]) if data["documentLocationInCreatingWorkspace"]
        super
      end
    end

    # - ResultIssueSummaries
    #   * Kind: object
    #   * Properties:
    #     + analyzerWarningSummaries: [IssueSummary]
    #     + errorSummaries: [IssueSummary]
    #     + testFailureSummaries: [TestFailureIssueSummary]
    #     + warningSummaries: [IssueSummary]
    class ResultIssueSummaries < AbstractObject
      attr_accessor :analyzer_warning_summaries
      attr_accessor :error_summaries
      attr_accessor :test_failure_summaries
      attr_accessor :warning_summaries
      def initialize(data)
        self.analyzer_warning_summaries = fetch_values(data, "analyzerWarningSummaries").map do |summary_data|
          IssueSummary.new(summary_data)
        end
        self.error_summaries = fetch_values(data, "errorSummaries").map do |summary_data|
          IssueSummary.new(summary_data)
        end
        self.test_failure_summaries = fetch_values(data, "testFailureSummaries").map do |summary_data|
          TestFailureIssueSummary.new(summary_data)
        end
        self.warning_summaries = fetch_values(data, "warningSummaries").map do |summary_data|
          IssueSummary.new(summary_data)
        end
        super
      end
    end

    # - TestFailureIssueSummary
    #   * Supertype: IssueSummary
    #   * Kind: object
    #   * Properties:
    #     + testCaseName: String
    class TestFailureIssueSummary < IssueSummary
      attr_accessor :test_case_name
      def initialize(data)
        self.test_case_name = fetch_value(data, "testCaseName")
        super
      end

      def failure_message
        new_message = self.message
        if self.document_location_in_creating_workspace&.url
          file_path = self.document_location_in_creating_workspace.url.gsub("file://", "")
          new_message += " (#{file_path})"
        end

        return new_message
      end
    end

    module Parser
      class << self
        def parse_xcresult(path:, output_remove_retry_attempts: false)
          require 'json'

          # Executes xcresulttool to get JSON format of the result bundle object
          # Hotfix: From Xcode 16 beta 3 'xcresulttool get --format json' has been deprecated; '--legacy' flag required to keep on using the command
          xcresulttool_cmd = generate_cmd_parse_xcresult(path)

          result_bundle_object_raw = execute_cmd(xcresulttool_cmd)
          result_bundle_object = JSON.parse(result_bundle_object_raw)

          # Parses JSON into ActionsInvocationRecord to find a list of all ids for ActionTestPlanRunSummaries
          actions_invocation_record = Trainer::LegacyXCResult::ActionsInvocationRecord.new(result_bundle_object)
          test_refs = actions_invocation_record.actions.map do |action|
            action.action_result.tests_ref
          end.compact
          ids = test_refs.map(&:id)

          # Maps ids into ActionTestPlanRunSummaries by executing xcresulttool to get JSON
          # containing specific information for each test summary,
          summaries = ids.map do |id|
            raw = execute_cmd([*xcresulttool_cmd, '--id', id])
            json = JSON.parse(raw)
            Trainer::LegacyXCResult::ActionTestPlanRunSummaries.new(json)
          end

          # Converts the ActionTestPlanRunSummaries to data for junit generator
          failures = actions_invocation_record.issues.test_failure_summaries || []
          summaries_to_data(summaries, failures, output_remove_retry_attempts: output_remove_retry_attempts)
        end

        private

        def summaries_to_data(summaries, failures, output_remove_retry_attempts: false)
          # Gets flat list of all ActionTestableSummary
          all_summaries = summaries.map(&:summaries).flatten
          testable_summaries = all_summaries.map(&:testable_summaries).flatten

          summaries_to_names = test_summaries_to_configuration_names(all_summaries)

          # Maps ActionTestableSummary to rows for junit generator
          rows = testable_summaries.map do |testable_summary|
            all_tests = testable_summary.all_tests.flatten

            # Used by store number of passes and failures by identifier
            # This is used when Xcode 13 (and up) retries tests
            # The identifier is duplicated until test succeeds or max count is reached
            tests_by_identifier = {}

            test_rows = all_tests.map do |test|
              identifier = "#{test.parent.name}.#{test.name}"
              test_row = {
                identifier: identifier,
                name: test.name,
                duration: test.duration,
                status: test.test_status,
                test_group: test.parent.name,

                # These don't map to anything but keeping empty strings
                guid: ""
              }

              info = tests_by_identifier[identifier] || {}
              info[:failure_count] ||= 0
              info[:skip_count] ||= 0
              info[:success_count] ||= 0

              retry_count = info[:retry_count]
              if retry_count.nil?
                retry_count = 0
              else
                retry_count += 1
              end
              info[:retry_count] = retry_count

              # Set failure message if failure found
              failure = test.find_failure(failures)
              if failure
                test_row[:failures] = [{
                  file_name: "",
                  line_number: 0,
                  message: "",
                  performance_failure: {},
                  failure_message: failure.failure_message
                }]

                info[:failure_count] += 1
              elsif test.test_status == "Skipped"
                test_row[:skipped] = true
                info[:skip_count] += 1
              else
                info[:success_count] = 1
              end

              tests_by_identifier[identifier] = info

              test_row
            end

            # Remove retry attempts from the count and test rows
            if output_remove_retry_attempts
              test_rows = test_rows.reject do |test_row|
                remove = false

                identifier = test_row[:identifier]
                info = tests_by_identifier[identifier]

                # Remove if this row is a retry and is a failure
                if info[:retry_count] > 0
                  remove = !(test_row[:failures] || []).empty?
                end

                # Remove all failure and retry count if test did eventually pass
                if remove
                  info[:failure_count] -= 1
                  info[:retry_count] -= 1
                  tests_by_identifier[identifier] = info
                end

                remove
              end
            end

            row = {
              project_path: testable_summary.project_relative_path,
              target_name: testable_summary.target_name,
              test_name: testable_summary.name,
              configuration_name: summaries_to_names[testable_summary],
              duration: all_tests.map(&:duration).inject(:+),
              tests: test_rows
            }

            row[:number_of_tests] = row[:tests].count
            row[:number_of_failures] = row[:tests].find_all { |a| (a[:failures] || []).count > 0 }.count

            # Used for seeing if any tests continued to fail after all of the Xcode 13 (and up) retries have finished
            unique_tests = tests_by_identifier.values || []
            row[:number_of_tests_excluding_retries] = unique_tests.count
            row[:number_of_skipped] = unique_tests.map { |a| a[:skip_count] }.inject(:+)
            row[:number_of_failures_excluding_retries] = unique_tests.find_all { |a| (a[:success_count] + a[:skip_count]) == 0 }.count
            row[:number_of_retries] = unique_tests.map { |a| a[:retry_count] }.inject(:+)

            row
          end

          rows
        end

        def test_summaries_to_configuration_names(test_summaries)
          summary_to_name = {}
          test_summaries.each do |summary|
            summary.testable_summaries.each do |testable_summary|
              summary_to_name[testable_summary] = summary.name
            end
          end
          summary_to_name
        end

        def generate_cmd_parse_xcresult(path)
          xcresulttool_cmd = [
            'xcrun',
            'xcresulttool',
            'get',
            '--format',
            'json',
            '--path',
            path
          ]

          xcresulttool_cmd << '--legacy' if Trainer::XCResult::Helper.supports_xcode16_xcresulttool?

          xcresulttool_cmd
        end

        def execute_cmd(cmd)
          output, status = Open3.capture2e(*cmd)
          raise "Failed to execute '#{cmd}': #{output}" unless status.success?
          return output
        end
      end
    end
  end
end
