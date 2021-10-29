require 'open3'
require 'fileutils'
require 'terminal-table'
require 'shellwords'

require 'fastlane_core/env'
require 'fastlane_core/device_manager'
require_relative 'module'
require_relative 'xcpretty_reporter_options_generator'
require_relative 'test_result_parser'
require_relative 'slack_poster'
require_relative 'test_command_generator'
require_relative 'error_handler'

module Scan
  class Runner
    def initialize
      @test_command_generator = TestCommandGenerator.new
      @device_boot_datetime = DateTime.now
    end

    def run
      handle_results(test_app)
    end

    def test_app
      force_quit_simulator_processes if Scan.config[:force_quit_simulator]

      if Scan.devices
        if Scan.config[:reset_simulator]
          Scan.devices.each do |device|
            FastlaneCore::Simulator.reset(udid: device.udid)
          end
        end

        if Scan.config[:disable_slide_to_type]
          Scan.devices.each do |device|
            FastlaneCore::Simulator.disable_slide_to_type(udid: device.udid)
          end
        end
      end

      prelaunch_simulators

      if Scan.config[:reinstall_app]
        app_identifier = Scan.config[:app_identifier]
        app_identifier ||= UI.input("App Identifier: ")

        Scan.devices.each do |device|
          FastlaneCore::Simulator.uninstall_app(app_identifier, device.name, device.udid)
        end
      end

      execute(retries: Scan.config[:number_of_retries])
    end

    def execute(retries: 0)
      Scan.cache[:retry_attempt] = Scan.config[:number_of_retries] - retries

      command = @test_command_generator.generate

      prefix_hash = [
        {
          prefix: "Running Tests: ",
          block: proc do |value|
            value.include?("Touching")
          end
        }
      ]
      exit_status = 0

      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                             prefix: prefix_hash,
                                            loading: "Loading...",
                                    suppress_output: Scan.config[:suppress_xcode_output],
                                              error: proc do |error_output|
                                                begin
                                                  exit_status = $?.exitstatus
                                                  if retries > 0
                                                    # If there are retries remaining, run the tests again
                                                    return retry_execute(retries: retries, error_output: error_output)
                                                  else
                                                    ErrorHandler.handle_build_error(error_output, @test_command_generator.xcodebuild_log_path)
                                                  end
                                                rescue => ex
                                                  SlackPoster.new.run({
                                                    build_errors: 1
                                                  })
                                                  raise ex
                                                end
                                              end)

      exit_status
    end

    def retry_execute(retries:, error_output: "")
      tests = retryable_tests(error_output)

      if tests.empty?
        UI.crash!("Failed to find failed tests to retry (could not parse error output)")
      end

      Scan.config[:only_testing] = tests
      UI.important("Retrying tests: #{Scan.config[:only_testing].join(', ')}")

      retries -= 1
      UI.important("Number of retries remaining: #{retries}")

      return execute(retries: retries)
    end

    def retryable_tests(input)
      input = Helper.strip_ansi_colors(input)

      retryable_tests = []

      failing_tests = input.split("Failing tests:\n").fetch(1, [])
                           .split("\n\n").first

      suites = failing_tests.split(/(?=\n\s+[\w\s]+:\n)/)

      suites.each do |suite|
        suite_name = suite.match(/\s*([\w\s\S]+):/).captures.first

        test_cases = suite.split(":\n").fetch(1, []).split("\n").each
                          .select { |line| line.match?(/^\s+/) }
                          .map { |line| line.strip.gsub(".", "/").gsub("()", "") }
                          .map { |line| suite_name + "/" + line }

        retryable_tests += test_cases
      end

      return retryable_tests.uniq
    end

    def handle_results(tests_exit_status)
      if Scan.config[:disable_xcpretty]
        unless tests_exit_status == 0
          UI.test_failure!("Test execution failed. Exit status: #{tests_exit_status}")
        end
        return
      end

      result = TestResultParser.new.parse_result(test_results)
      SlackPoster.new.run(result)

      if result[:failures] > 0
        failures_str = result[:failures].to_s.red
      else
        failures_str = result[:failures].to_s.green
      end

      puts(Terminal::Table.new({
        title: "Test Results",
        rows: [
          ["Number of tests", result[:tests]],
          ["Number of failures", failures_str]
        ]
      }))
      puts("")

      copy_simulator_logs
      zip_build_products
      copy_xctestrun

      if result[:failures] > 0
        open_report

        UI.test_failure!("Tests have failed")
      end

      unless tests_exit_status == 0
        UI.test_failure!("Test execution failed. Exit status: #{tests_exit_status}")
      end

      open_report
    end

    def open_report
      if !Helper.ci? && Scan.cache[:open_html_report_path]
        `open --hide '#{Scan.cache[:open_html_report_path]}'`
      end
    end

    def zip_build_products
      return unless Scan.config[:should_zip_build_products]

      # Gets :derived_data_path/Build/Products directory for zipping zip
      derived_data_path = Scan.config[:derived_data_path]
      path = File.join(derived_data_path, "Build/Products")

      # Gets absolute path of output directory
      output_directory = File.absolute_path(Scan.config[:output_directory])
      output_path = File.join(output_directory, "build_products.zip")

      # Caching path for action to put into lane_context
      Scan.cache[:zip_build_products_path] = output_path

      # Zips build products and moves it to output directory
      UI.message("Zipping build products")
      FastlaneCore::Helper.zip_directory(path, output_path, contents_only: true, overwrite: true, print: false)
      UI.message("Successfully zipped build products: #{output_path}")
    end

    def copy_xctestrun
      return unless Scan.config[:output_xctestrun]

      # Gets :derived_data_path/Build/Products directory for coping .xctestrun file
      derived_data_path = Scan.config[:derived_data_path]
      path = File.join(derived_data_path, "Build", "Products")

      # Gets absolute path of output directory
      output_directory = File.absolute_path(Scan.config[:output_directory])
      output_path = File.join(output_directory, "settings.xctestrun")

      # Caching path for action to put into lane_context
      Scan.cache[:output_xctestrun] = output_path

      # Copy .xctestrun file and moves it to output directory
      UI.message("Copying .xctestrun file")
      xctestrun_file = Dir.glob("#{path}/*.xctestrun").first

      if xctestrun_file
        FileUtils.cp(xctestrun_file, output_path)
        UI.message("Successfully copied xctestrun file: #{output_path}")
      else
        UI.user_error!("Could not find .xctestrun file to copy")
      end
    end

    def test_results
      temp_junit_report = Scan.cache[:temp_junit_report]
      return File.read(temp_junit_report) if temp_junit_report && File.file?(temp_junit_report)

      # Something went wrong with the temp junit report for the test success/failures count.
      # We'll have to regenerate from the xcodebuild log, like we did before version 2.34.0.
      UI.message("Generating test results. This may take a while for large projects.")

      reporter_options_generator = XCPrettyReporterOptionsGenerator.new(false, [], [], "", false, nil)
      reporter_options = reporter_options_generator.generate_reporter_options
      xcpretty_args_options = reporter_options_generator.generate_xcpretty_args_options
      cmd = "cat #{@test_command_generator.xcodebuild_log_path.shellescape} | xcpretty #{reporter_options.join(' ')} #{xcpretty_args_options} &> /dev/null"
      system(cmd)
      File.read(Scan.cache[:temp_junit_report])
    end

    def prelaunch_simulators
      return unless Scan.devices.to_a.size > 0 # no devices selected, no sims to launch

      # Return early unless the user wants to prelaunch simulators. Or if the user wants simulator logs
      # then we must prelaunch simulators because Xcode's headless
      # mode launches and shutsdown the simulators before we can collect the logs.
      return unless Scan.config[:prelaunch_simulator] || Scan.config[:include_simulator_logs]

      devices_to_shutdown = []
      Scan.devices.each do |device|
        devices_to_shutdown << device if device.state == "Shutdown"
        device.boot
      end
      at_exit do
        devices_to_shutdown.each(&:shutdown)
      end
    end

    def copy_simulator_logs
      return unless Scan.config[:include_simulator_logs]

      UI.header("Collecting system logs")
      Scan.devices.each do |device|
        log_identity = "#{device.name}_#{device.os_type}_#{device.os_version}"
        FastlaneCore::Simulator.copy_logs(device, log_identity, Scan.config[:output_directory], @device_boot_datetime)
      end
    end

    def force_quit_simulator_processes
      # Silently execute and kill, verbose flags will show this command occurring
      Fastlane::Actions.sh("killall Simulator &> /dev/null || true", log: false)
    end
  end
end
