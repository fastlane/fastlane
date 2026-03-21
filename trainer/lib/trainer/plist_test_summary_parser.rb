require 'plist'

module Trainer
  module PlistTestSummaryParser
    class << self
      def parse_content(raw_json, xcpretty_naming)
        data = raw_json["TestableSummaries"].collect do |testable_summary|
          summary_row = {
            project_path: testable_summary["ProjectPath"],
            target_name: testable_summary["TargetName"],
            test_name: testable_summary["TestName"],
            duration: testable_summary["Tests"].map { |current_test| current_test["Duration"] }.inject(:+),
            tests: unfold_tests(testable_summary["Tests"]).collect do |current_test|
              test_group, test_name = test_group_and_name(testable_summary, current_test, xcpretty_naming)
              current_row = {
                identifier: current_test["TestIdentifier"],
                test_group: test_group,
                name: test_name,
                object_class: current_test["TestObjectClass"],
                status: current_test["TestStatus"],
                guid: current_test["TestSummaryGUID"],
                duration: current_test["Duration"]
              }
              if current_test["FailureSummaries"]
                current_row[:failures] = current_test["FailureSummaries"].collect do |current_failure|
                  {
                    file_name: current_failure['FileName'],
                    line_number: current_failure['LineNumber'],
                    message: current_failure['Message'],
                    performance_failure: current_failure['PerformanceFailure'],
                    failure_message: "#{current_failure['Message']} (#{current_failure['FileName']}:#{current_failure['LineNumber']})"
                  }
                end
              end
              current_row
            end
          }
          summary_row[:number_of_tests] = summary_row[:tests].count
          summary_row[:number_of_failures] = summary_row[:tests].find_all { |a| (a[:failures] || []).count > 0 }.count

          # Makes sure that plist support matches data output of xcresult
          summary_row[:number_of_tests_excluding_retries] = summary_row[:number_of_tests]
          summary_row[:number_of_failures_excluding_retries] = summary_row[:number_of_failures]
          summary_row[:number_of_retries] = 0

          summary_row
        end
        data
      end

      def ensure_file_valid!(raw_json)
        format_version = raw_json["FormatVersion"]
        supported_versions = ["1.1", "1.2"]
        raise "Format version '#{format_version}' is not supported, must be #{supported_versions.join(', ')}" unless supported_versions.include?(format_version)
      end

      private

      def unfold_tests(data)
        tests = []
        data.each do |current_hash|
          if current_hash["Subtests"]
            tests += unfold_tests(current_hash["Subtests"])
          end
          if current_hash["TestStatus"]
            tests << current_hash
          end
        end
        return tests
      end

      def test_group_and_name(testable_summary, test, xcpretty_naming)
        if xcpretty_naming
          group = testable_summary["TargetName"] + "." + test["TestIdentifier"].split("/")[0..-2].join(".")
          name = test["TestName"][0..-3]
        else
          group = test["TestIdentifier"].split("/")[0..-2].join(".")
          name = test["TestName"]
        end
        return group, name
      end
    end
  end
end
