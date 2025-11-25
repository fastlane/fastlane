require 'plist'

require 'fastlane_core/print_table'

require_relative 'xcresult'
require_relative 'xcresult/helper'
require_relative 'junit_generator'
require_relative 'legacy_xcresult'
require_relative 'plist_test_summary_parser'
require_relative 'module'

module Trainer
  class TestParser
    attr_accessor :data

    attr_accessor :number_of_tests
    attr_accessor :number_of_failures
    attr_accessor :number_of_tests_excluding_retries
    attr_accessor :number_of_failures_excluding_retries
    attr_accessor :number_of_retries
    attr_accessor :number_of_skipped

    # Returns a hash with the path being the key, and the value
    # defining if the tests were successful
    def self.auto_convert(config)
      unless config[:silent]
        FastlaneCore::PrintTable.print_values(config: config,
                                               title: "Summary for trainer #{Fastlane::VERSION}")
      end

      containing_dir = config[:path]
      # Xcode < 10
      files = Dir["#{containing_dir}/**/Logs/Test/*TestSummaries.plist"]
      files += Dir["#{containing_dir}/Test/*TestSummaries.plist"]
      files += Dir["#{containing_dir}/*TestSummaries.plist"]
      # Xcode 10
      files += Dir["#{containing_dir}/**/Logs/Test/*.xcresult/TestSummaries.plist"]
      files += Dir["#{containing_dir}/Test/*.xcresult/TestSummaries.plist"]
      files += Dir["#{containing_dir}/*.xcresult/TestSummaries.plist"]
      files += Dir[containing_dir] if containing_dir.end_with?(".plist") # if it's the exact path to a plist file
      # Xcode 11
      files += Dir["#{containing_dir}/**/Logs/Test/*.xcresult"]
      files += Dir["#{containing_dir}/Test/*.xcresult"]
      files += Dir["#{containing_dir}/*.xcresult"]
      files << containing_dir if File.extname(containing_dir) == ".xcresult"

      if files.empty?
        UI.user_error!("No test result files found in directory '#{containing_dir}', make sure the file name ends with 'TestSummaries.plist' or '.xcresult'")
      end

      return_hash = {}
      files.each do |path|
        extension = config[:extension]
        output_filename = config[:output_filename]

        should_write_file = !extension.nil? || !output_filename.nil?

        if should_write_file
          if config[:output_directory]
            FileUtils.mkdir_p(config[:output_directory])
            # Remove .xcresult or .plist extension
            # Use custom file name ONLY if one file otherwise issues
            if files.size == 1 && output_filename
              filename = output_filename
            elsif path.end_with?(".xcresult")
              filename ||= File.basename(path).gsub(".xcresult", extension)
            else
              filename ||= File.basename(path).gsub(".plist", extension)
            end
            to_path = File.join(config[:output_directory], filename)
          else
            # Remove .xcresult or .plist extension
            if path.end_with?(".xcresult")
              to_path = path.gsub(".xcresult", extension)
            else
              to_path = path.gsub(".plist", extension)
            end
          end
        end

        tp = Trainer::TestParser.new(path, config)
        File.write(to_path, tp.to_junit) if should_write_file
        UI.success("Successfully generated '#{to_path}'") if should_write_file && !config[:silent]

        return_hash[path] = {
          to_path: to_path,
          successful: tp.tests_successful?,
          number_of_tests: tp.number_of_tests,
          number_of_failures: tp.number_of_failures,
          number_of_tests_excluding_retries: tp.number_of_tests_excluding_retries,
          number_of_failures_excluding_retries: tp.number_of_failures_excluding_retries,
          number_of_retries: tp.number_of_retries,
          number_of_skipped: tp.number_of_skipped
        }
      end
      return_hash
    end

    def initialize(path, config = {})
      path = File.expand_path(path)
      UI.user_error!("File not found at path '#{path}'") unless File.exist?(path)

      if File.directory?(path) && path.end_with?(".xcresult")
        parser = XCResult::Helper.supports_xcode16_xcresulttool? && !config[:force_legacy_xcresulttool] ? XCResult::Parser : LegacyXCResult::Parser
        self.data = parser.parse_xcresult(path: path, output_remove_retry_attempts: config[:output_remove_retry_attempts])
      else
        file_content = File.read(path)
        raw_json = Plist.parse_xml(file_content)

        return if raw_json["FormatVersion"].to_s.length.zero? # maybe that's a useless plist file

        PlistTestSummaryParser.ensure_file_valid!(raw_json)
        self.data = PlistTestSummaryParser.parse_content(raw_json, config[:xcpretty_naming])
      end

      self.number_of_tests = 0
      self.number_of_failures = 0
      self.number_of_tests_excluding_retries = 0
      self.number_of_failures_excluding_retries = 0
      self.number_of_retries = 0
      self.number_of_skipped = 0
      self.data.each do |thing|
        self.number_of_tests += thing[:number_of_tests].to_i
        self.number_of_failures += thing[:number_of_failures].to_i
        self.number_of_tests_excluding_retries += thing[:number_of_tests_excluding_retries].to_i
        self.number_of_failures_excluding_retries += thing[:number_of_failures_excluding_retries].to_i
        self.number_of_retries += thing[:number_of_retries].to_i
        self.number_of_skipped += thing[:number_of_skipped].to_i
      end
    end

    # Returns the JUnit report as String
    def to_junit
      self.data.kind_of?(Trainer::XCResult::TestPlan) ? self.data.to_xml : JunitGenerator.new(self.data).generate
    end

    # @return [Bool] were all tests successful? Is false if at least one test failed
    def tests_successful?
      self.data.collect { |a| a[:number_of_failures_excluding_retries] }.all?(&:zero?)
    end
  end
end
