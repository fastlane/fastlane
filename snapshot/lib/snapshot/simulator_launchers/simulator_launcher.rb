require 'snapshot/simulator_launchers/simulator_launcher_base'

module Snapshot
  class SimulatorLauncher < SimulatorLauncherBase
    def default_number_of_simultaneous_simulators
      cpu_count = CPUInspector.cpu_count
      if cpu_count <= 2
        return cpu_count
      end

      return cpu_count - 1
    end

    def take_screenshots_simultaneously
      languages_finished = {}
      launcher_config.launch_args_set.each do |launch_args|
        launcher_config.languages.each_with_index do |language, language_index|
          locale = nil
          if language.kind_of?(Array)
            locale = language[1]
            language = language[0]
          end

          # Clear logs so subsequent xcodebuild executions dont append to old ones
          log_path = xcodebuild_log_path(language: language, locale: locale)
          File.delete(log_path) if File.exist?(log_path)

          # Break up the array of devices into chunks that can
          # be run simultaneously.
          if launcher_config.serialized_executions
            # Put each device in it's own array to run tests one at a time
            device_batches = launcher_config.devices.map { |d| [d] }
          else
            device_batches = launcher_config.devices.each_slice(default_number_of_simultaneous_simulators).to_a
          end

          device_batches.each do |devices|
            languages_finished[language] = launch_simultaneously(devices, language, locale, launch_args)
          end
        end
      end
      launcher_config.devices.each_with_object({}) do |device, results_hash|
        results_hash[device] = languages_finished
      end
    end

    def launch_simultaneously(devices, language, locale, launch_arguments)
      prepare_for_launch(language, locale, launch_arguments)

      add_media(devices, :photo, launcher_config.add_photos) if launcher_config.add_photos
      add_media(devices, :video, launcher_config.add_videos) if launcher_config.add_videos

      command = TestCommandGenerator.generate(
        devices: devices,
        language: language,
        locale: locale,
        log_path: xcodebuild_log_path(language: language, locale: locale)
      )

      prefix_hash = [
        {
          prefix: "Running Tests: ",
          block: proc do |value|
            value.include?("Touching")
          end
        }
      ]

      UI.important("Running snapshot on: #{devices.join(', ')}")

      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: true,
                                      print_command: true,
                                             prefix: prefix_hash,
                                            loading: "Loading...",
                                              error: proc do |output, return_code|
                                                ErrorHandler.handle_test_error(output, return_code)

                                                # no exception raised... that means we need to retry
                                                UI.error "Caught error... #{return_code}"

                                                self.current_number_of_retries_due_to_failing_simulator += 1
                                                if self.current_number_of_retries_due_to_failing_simulator < 20
                                                  launch_simultaneously(language, locale, launch_arguments)
                                                else
                                                  # It's important to raise an error, as we don't want to collect the screenshots
                                                  UI.crash!("Too many errors... no more retries...")
                                                end
                                              end)
      raw_output = File.read(xcodebuild_log_path(language: language, locale: locale))

      dir_name = locale || language

      return Collector.fetch_screenshots(raw_output, dir_name, '', launch_arguments.first)
    end

    def xcodebuild_log_path(language: nil, locale: nil)
      name_components = [Snapshot.project.app_name, Snapshot.config[:scheme]]

      if Snapshot.config[:namespace_log_files]
        name_components << launcher_config.devices.join('-') if launcher_config.devices.count >= 1
        name_components << language if language
        name_components << locale if locale
      end

      file_name = "#{name_components.join('-')}.log"

      containing = File.expand_path(Snapshot.config[:buildlog_path])
      FileUtils.mkdir_p(containing)

      return File.join(containing, file_name)
    end
  end

  class CPUInspector
    def self.hwprefs_available?
      `which hwprefs` != ''
    end

    def self.cpu_count
      @cpu_count ||=
        case RUBY_PLATFORM
        when /darwin9/
          `hwprefs cpu_count`.to_i
        when /darwin10/
          (hwprefs_available? ? `hwprefs thread_count` : `sysctl -n hw.physicalcpu_max`).to_i
        when /linux/
          `cat /proc/cpuinfo | grep processor | wc -l`.to_i
        when /freebsd/
          `sysctl -n hw.physicalcpu_max`.to_i
        else
          if RbConfig::CONFIG['host_os'] =~ /darwin/
            (hwprefs_available? ? `hwprefs thread_count` : `sysctl -n hw.physicalcpu_max`).to_i
          else
            raise 'unknown platform processor_count'
          end
        end
    end
  end
end
