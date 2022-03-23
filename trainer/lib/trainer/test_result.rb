module Trainer
  module TestResult
    class AbstractObject
      attr_accessor :object_class
      def initialize(data)
        self.object_class = data['TestObjectClass']
      end
    end

    # - ActionTestableSummary
    #   * Kind: object
    #   * Properties:
    #     + project_path: String
    #     + target_name: String
    #     + test_name: String
    #     + tests: [Test]
    class ActionTestableSummary < AbstractObject
      attr_accessor :project_path
      attr_accessor :target_name
      attr_accessor :test_name
      attr_accessor :tests
      def initialize(data)
        self.project_path = data['ProjectPath']
        self.target_name = data['TargetName']
        self.test_name = data['TestName']
        self.tests = data['Tests'].collect do |test_data|
          ActionTestSummaryIdentifiableObject.create(test_data)
        end
        super
      end

      def all_tests
        tests.map(&:all_subtests).flatten
      end
    end

    # - ActionTestSummaryIdentifiableObject
    #   * Kind: object
    #   * Properties:
    #     + identifier: String
    #     + name: String
    #     + duration: Double
    class ActionTestSummaryIdentifiableObject < AbstractObject
      attr_accessor :identifier
      attr_accessor :name
      attr_accessor :duration
      def initialize(data)
        self.identifier = data['TestIdentifier']
        self.name = data['TestName']
        self.duration = data['Duration']
        super
      end

      def all_subtests
        raise 'Not overridden'
      end

      def self.create(data)
        type = data['TestObjectClass']
        if type == 'IDESchemeActionTestSummaryGroup'
          ActionTestSummaryGroup.new(data)
        elsif type == 'IDESchemeActionTestSummary'
          ActionTestSummary.new(data)
        else
          raise "Unsupported type: #{type}"
        end
      end
    end

    # - ActionTestSummaryGroup
    #   * Kind: object
    #   * Properties:
    #     + subtests: [Test]
    class ActionTestSummaryGroup < ActionTestSummaryIdentifiableObject
      attr_accessor :subtests
      def initialize(data)
        self.subtests = (data['Subtests'] || []).collect do |subtests_data|
          ActionTestSummaryIdentifiableObject.create(subtests_data)
        end
        super
      end

      def all_subtests
        subtests.map(&:all_subtests).flatten
      end
    end

    # - ActionTestSummary
    #   * Kind: object
    #   * Properties:
    #     + status: String
    #     + summary_guid: String
    #     + activity_summaries: [ActivitySummaries]?
    #     + failure_summaries: [FailureSummary]?
    class ActionTestSummary < ActionTestSummaryIdentifiableObject
      attr_accessor :status
      attr_accessor :summary_guid
      attr_accessor :failure_summaries
      def initialize(data)
        self.status = data['TestStatus']
        self.summary_guid = data['TestSummaryGUID']
        self.failure_summaries = (data['FailureSummaries'] || []).collect do |summary_data|
          ActionTestFailureSummary.new(summary_data)
        end
        super
      end

      def all_subtests
        [self]
      end
    end

    # - ActionTestFailureSummary
    #   * Kind: object
    #   * Properties:
    #     + file_name: String
    #     + line_number: Int
    #     + message: String
    #     + performance_failure: Bool
    class ActionTestFailureSummary < AbstractObject
      attr_accessor :file_name
      attr_accessor :line_number
      attr_accessor :message
      attr_accessor :performance_failure
      def initialize(data)
        self.file_name = data['FileName']
        self.line_number = data['LineNumber']
        self.message = data['Message']
        self.performance_failure = data['PerformanceFailure']
        super
      end

      def failure_message
        "#{message} (#{file_name}:#{line_number})"
      end
    end
  end
end
