module Fastlane
  module Actions
    module SharedValues
      SCAN_DERIVED_DATA_PATH = :SCAN_DERIVED_DATA_PATH
      SCAN_GENERATED_PLIST_FILE = :SCAN_GENERATED_PLIST_FILE
      SCAN_GENERATED_PLIST_FILES = :SCAN_GENERATED_PLIST_FILES
      SCAN_GENERATED_XCRESULT_PATH = :SCAN_GENERATED_XCRESULT_PATH
      SCAN_ZIP_BUILD_PRODUCTS_PATH = :SCAN_ZIP_BUILD_PRODUCTS_PATH
    end

    class RunTestsAction < Action
      def self.run(values)
        require 'scan'
        manager = Scan::Manager.new

        begin
          results = manager.work(values)

          zip_build_products_path = Scan.cache[:zip_build_products_path]
          Actions.lane_context[SharedValues::SCAN_ZIP_BUILD_PRODUCTS_PATH] = zip_build_products_path if zip_build_products_path

          return results
        rescue FastlaneCore::Interface::FastlaneBuildFailure => ex
          # Specifically catching FastlaneBuildFailure to prevent build/compile errors from being
          # silenced when :fail_build is set to false
          # :fail_build should only suppress testing failures
          raise ex
        rescue => ex
          if values[:fail_build]
            raise ex
          end
        ensure
          if Scan.cache && (result_bundle_path = Scan.cache[:result_bundle_path])
            Actions.lane_context[SharedValues::SCAN_GENERATED_XCRESULT_PATH] = File.absolute_path(result_bundle_path)
          else
            Actions.lane_context[SharedValues::SCAN_GENERATED_XCRESULT_PATH] = nil
          end

          unless values[:derived_data_path].to_s.empty?
            plist_files_before = manager.plist_files_before || []

            Actions.lane_context[SharedValues::SCAN_DERIVED_DATA_PATH] = values[:derived_data_path]
            plist_files_after = manager.test_summary_filenames(values[:derived_data_path])
            all_test_summaries = (plist_files_after - plist_files_before)
            Actions.lane_context[SharedValues::SCAN_GENERATED_PLIST_FILES] = all_test_summaries
            Actions.lane_context[SharedValues::SCAN_GENERATED_PLIST_FILE] = all_test_summaries.last
          end
        end
      end

      def self.description
        "Easily run tests of your iOS app (via _scan_)"
      end

      def self.details
        "More information: https://docs.fastlane.tools/actions/scan/"
      end

      def self.return_value
        'Outputs hash of results with the following keys: :number_of_tests, :number_of_failures, :number_of_retries, :number_of_tests_excluding_retries, :number_of_failures_excluding_retries'
      end

      def self.return_type
        :hash
      end

      def self.author
        "KrauseFx"
      end

      def self.available_options
        require 'scan'

        FastlaneCore::CommanderGenerator.new.generate(Scan::Options.available_options)
      end

      def self.output
        [
          ['SCAN_DERIVED_DATA_PATH', 'The path to the derived data'],
          ['SCAN_GENERATED_PLIST_FILE', 'The generated plist file'],
          ['SCAN_GENERATED_PLIST_FILES', 'The generated plist files'],
          ['SCAN_GENERATED_XCRESULT_PATH', 'The path to the generated .xcresult'],
          ['SCAN_ZIP_BUILD_PRODUCTS_PATH', 'The path to the zipped build products']
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      private_class_method

      def self.example_code
        [
          'run_tests',
          'scan # alias for "run_tests"',
          'run_tests(
            workspace: "App.xcworkspace",
            scheme: "MyTests",
            clean: false
          )',
          '# Build For Testing
          run_tests(
             derived_data_path: "my_folder",
             build_for_testing: true
          )',
          '# run tests using derived data from prev. build
          run_tests(
             derived_data_path: "my_folder",
             test_without_building: true
          )',
          '# or run it from an existing xctestrun package
          run_tests(
             xctestrun: "/path/to/mytests.xctestrun"
          )'
        ]
      end

      def self.category
        :testing
      end
    end
  end
end
