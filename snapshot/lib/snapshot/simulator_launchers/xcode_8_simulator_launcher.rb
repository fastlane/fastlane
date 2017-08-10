require 'snapshot/simulator_launchers/simulator_launcher'

module Snapshot
  class Xcode8SimulatorLauncher < SimulatorLauncher
    def take_screenshots_one_simulator_at_a_time(launch_arguments)
      results = {} # collect all the results for a nice table
      Snapshot.config[:devices].each_with_index do |device, device_index|
        launch_arguments.each do |launch_args|
          Snapshot.config[:languages].each_with_index do |language, language_index|
            locale = nil
            if language.kind_of?(Array)
              locale = language[1]
              language = language[0]
            end
            results[device] ||= {}

            current_run = device_index * Snapshot.config[:languages].count + language_index + 1
            number_of_runs = Snapshot.config[:languages].count * Snapshot.config[:devices].count
            UI.message("snapshot run #{current_run} of #{number_of_runs}")
            results[device][language] = run_for_device_and_language(language, locale, device, launch_args)
            copy_simulator_logs(device, language, locale, launch_args)
          end
        end
      end
      results
    end

    # This is its own method so that it can re-try if the tests fail randomly
    # @return true/false depending on if the tests succeeded
    def run_for_device_and_language(language, locale, device, launch_arguments, retries = 0)
      return launch_one_at_a_time(language, locale, device, launch_arguments)
    rescue => ex
      UI.error ex.to_s # show the reason for failure to the user, but still maybe retry

      if retries < Snapshot.config[:number_of_retries]
        UI.important "Tests failed, re-trying #{retries + 1} out of #{Snapshot.config[:number_of_retries] + 1} times"
        run_for_device_and_language(language, locale, device, launch_arguments, retries + 1)
      else
        UI.error "Backtrace:\n\t#{ex.backtrace.join("\n\t")}" if FastlaneCore::Globals.verbose?
        self.collected_errors << ex
        raise ex if Snapshot.config[:stop_after_first_error]
        return false # for the results
      end
    end

    # Returns true if it succeeded
    def launch_one_at_a_time(language, locale, device_type, launch_arguments)
      prepare_for_launch(language, locale, launch_arguments)

      add_media(device_type, :photo, Snapshot.config[:add_photos]) if Snapshot.config[:add_photos]
      add_media(device_type, :video, Snapshot.config[:add_videos]) if Snapshot.config[:add_videos]

      open_simulator_for_device(device_type)

      command = TestCommandGenerator.generate(device_type: device_type, language: language, locale: locale)

      if locale
        UI.header("#{device_type} - #{language} (#{locale})")
      else
        UI.header("#{device_type} - #{language}")
      end

      prefix_hash = [
        {
          prefix: "Running Tests: ",
          block: proc do |value|
            value.include?("Touching")
          end
        }
      ]

      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                             prefix: prefix_hash,
                                            loading: "Loading...",
                                              error: proc do |output, return_code|
                                                ErrorHandler.handle_test_error(output, return_code)

                                                # no exception raised... that means we need to retry
                                                UI.error "Caught error... #{return_code}"

                                                self.number_of_retries_due_to_failing_simulator += 1
                                                if self.number_of_retries_due_to_failing_simulator < 20
                                                  launch_one_at_a_time(language, locale, device_type, launch_arguments)
                                                else
                                                  # It's important to raise an error, as we don't want to collect the screenshots
                                                  UI.crash!("Too many errors... no more retries...")
                                                end
                                              end)

      raw_output = File.read(TestCommandGenerator.xcodebuild_log_path(device_type: device_type, language: language, locale: locale))

      dir_name = locale || language

      return Collector.fetch_screenshots(raw_output, dir_name, device_type, launch_arguments.first)
    end

    def copy_simulator_logs(device_name, language, locale, launch_arguments)
      return unless Snapshot.config[:output_simulator_logs]

      detected_language = locale || language
      language_folder = File.join(Snapshot.config[:output_directory], detected_language)
      device = TestCommandGenerator.find_device(device_name)
      components = [launch_arguments].delete_if { |a| a.to_s.length == 0 }

      UI.header("Collecting system logs #{device_name} - #{language}")
      log_identity = Digest::MD5.hexdigest(components.join("-"))
      FastlaneCore::Simulator.copy_logs(device, log_identity, language_folder)
    end

    def open_simulator_for_device(device_name)
      return unless FastlaneCore::Env.truthy?('FASTLANE_EXPLICIT_OPEN_SIMULATOR')

      device = TestCommandGenerator.find_device(device_name)
      FastlaneCore::Simulator.launch(device) if device
    end
  end
end
