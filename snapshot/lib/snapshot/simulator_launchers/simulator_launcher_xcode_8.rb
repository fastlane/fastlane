require_relative 'simulator_launcher_base'
require_relative '../error_handler'
require_relative '../collector'
require_relative '../test_command_generator_xcode_8'

module Snapshot
  class SimulatorLauncherXcode8 < SimulatorLauncherBase
    def take_screenshots_one_simulator_at_a_time
      results = {} # collect all the results for a nice table
      launcher_config.devices.each_with_index do |device, device_index|
        # launch_args_set always has at at least 1 item (could be "")
        launcher_config.launch_args_set.each do |launch_args|
          launcher_config.languages.each_with_index do |language, language_index|
            locale = nil
            if language.kind_of?(Array)
              locale = language[1]
              language = language[0]
            end
            results[device] ||= {}

            current_run = device_index * launcher_config.languages.count + language_index + 1
            number_of_runs = launcher_config.languages.count * launcher_config.devices.count
            UI.message("snapshot run #{current_run} of #{number_of_runs}")
            results[device][language] = run_for_device_and_language(language, locale, device, launch_args)
            copy_simulator_logs([device], language, locale, launch_args)
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
      UI.error(ex.to_s) # show the reason for failure to the user, but still maybe retry

      if retries < launcher_config.number_of_retries
        UI.important("Tests failed, re-trying #{retries + 1} out of #{launcher_config.number_of_retries + 1} times")
        run_for_device_and_language(language, locale, device, launch_arguments, retries + 1)
      else
        UI.error("Backtrace:\n\t#{ex.backtrace.join("\n\t")}") if FastlaneCore::Globals.verbose?
        self.collected_errors << ex
        raise ex if launcher_config.stop_after_first_error
        return false # for the results
      end
    end

    # Returns true if it succeeded
    def launch_one_at_a_time(language, locale, device_type, launch_arguments)
      prepare_for_launch([device_type], language, locale, launch_arguments)

      add_media([device_type], :photo, launcher_config.add_photos) if launcher_config.add_photos
      add_media([device_type], :video, launcher_config.add_videos) if launcher_config.add_videos

      open_simulator_for_device(device_type)

      command = TestCommandGeneratorXcode8.generate(device_type: device_type, language: language, locale: locale)

      if locale
        UI.header("#{device_type} - #{language} (#{locale})")
      else
        UI.header("#{device_type} - #{language}")
      end

      execute(command: command, language: language, locale: locale, device_type: device_type, launch_args: launch_arguments)

      raw_output = File.read(TestCommandGeneratorXcode8.xcodebuild_log_path(device_type: device_type, language: language, locale: locale))

      dir_name = locale || language

      return Collector.fetch_screenshots(raw_output, dir_name, device_type, launch_arguments.first)
    end

    def execute(command: nil, language: nil, locale: nil, device_type: nil, launch_args: nil)
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
                                                UI.error("Caught error... #{return_code}")

                                                self.current_number_of_retries_due_to_failing_simulator += 1
                                                if self.current_number_of_retries_due_to_failing_simulator < 20
                                                  launch_one_at_a_time(language, locale, device_type, launch_arguments)
                                                else
                                                  # It's important to raise an error, as we don't want to collect the screenshots
                                                  UI.crash!("Too many errors... no more retries...")
                                                end
                                              end)
    end

    def open_simulator_for_device(device_name)
      return unless FastlaneCore::Env.truthy?('FASTLANE_EXPLICIT_OPEN_SIMULATOR')

      device = TestCommandGeneratorBase.find_device(device_name)
      FastlaneCore::Simulator.launch(device) if device
    end
  end
end
