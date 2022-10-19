require 'fastlane_core/print_table'
require_relative 'module'
require_relative 'runner'

module Scan
  class Manager
    attr_accessor :plist_files_before

    def work(options)
      Scan.config = options # we set this here to auto-detect missing values, which we need later on
      unless options[:derived_data_path].to_s.empty?
        self.plist_files_before = test_summary_filenames(Scan.config[:derived_data_path])
      end

      # Also print out the path to the used Xcode installation
      # We go 2 folders up, to not show "Contents/Developer/"
      values = Scan.config.values(ask: false)
      values[:xcode_path] = File.expand_path("../..", FastlaneCore::Helper.xcode_path)
      FastlaneCore::PrintTable.print_values(config: values,
                                         hide_keys: [:destination, :slack_url],
                                             title: "Summary for scan #{Fastlane::VERSION}")

      return Runner.new.run
    end

    def test_summary_filenames(derived_data_path)
      files = []

      # Xcode < 10
      files += Dir["#{derived_data_path}/**/Logs/Test/*TestSummaries.plist"]

      # Xcode 10
      files += Dir["#{derived_data_path}/**/Logs/Test/*.xcresult/TestSummaries.plist"]

      return files
    end
  end
end
