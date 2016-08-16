require 'open3'
require 'tempfile'

module Fastlane
  module Actions
    module SharedValues
    end

    class InstrumentedTestsAction < Action
      def self.run(params)
        gradle = Helper::GradleHelper.new(gradle_path: Dir["./gradlew"].last)
        file = Tempfile.new('emulator_output')

        # Set up params
        avd_name = "--name \"#{params[:avd_name]}\""
        target_id = "--target #{params[:target_id]}"
        avd_options = params[:avd_options] unless params[:avd_options].nil?
        avd_abi = "--abi #{params[:avd_abi]}" unless params[:avd_abi].nil?
        avd_tag = "--tag #{params[:avd_tag]}" unless params[:avd_tag].nil?
        create_avd = ["#{params[:sdk_path]}/tools/android", "create avd", avd_name, target_id, avd_abi, avd_tag, avd_options].join(" ")
        start_avd = ["#{params[:sdk_path]}/tools/emulator", "-avd #{params[:avd_name]}", "-gpu on -no-boot-anim &>#{file.path} &"]
        devices = `#{params[:sdk_path]}/tools/android list avd`.chomp

        # Delete avd if one already exists for clean state.
        unless devices.match(/#{params[:avd_name]}/).nil?
          Action.sh("#{params[:sdk_path]}/tools/android delete avd -n #{params[:avd_name]}")
        end

        Helper.log.info("Creating AVD...".yellow)
        Action.sh(create_avd)

        Helper.log.info("Starting AVD....".yellow)
        begin
          Action.sh(start_avd)

          # Wait for device to be fully
          boot_emulator

          Helper.log.info("Executing gradle command...".green)
          begin
            gradle.trigger(task: params[:task], flags: params[:flags], serial: nil)
          ensure
            stop_emulator
          end
        ensure
          file.close
          file.unlink
        end
      end

      def self.boot_emulator
        Helper.log.info("Waiting for emulator to finish booting.....".yellow)
        loop do
          stdout, _stdeerr, _status = Open3.capture3("#{params[:sdk_path]}/platform-tools/adb shell getprop sys.boot_completed")

          if stdout.strip == "1"
            Helper.log.info("Emulator Booted!".green)
            break
          end
        end
      end

      def self.stop_emulator
        adb = Helper::AdbHelper.new(adb_path: "#{params[:sdk_path]}/platform-tools/adb")
        temp = File.open(file.path).read
        port = temp.match(/console on port (\d+),/)

        if port
          port = port[1]
        else
          Helper.log.info("Could not find emulator port number, using default port.".yellow)
          port = "5554"
        end

        Helper.log.info("Shutting down emulator...".green)
        adb.trigger(command: "emu kill", serial: "emulator-#{port}")

        Helper.log.info("Deleting emulator....".green)
        Action.sh("#{params[:sdk_path]}/tools/android delete avd -n #{params[:avd_name]}")
      end

      def self.description
        "Run android instrumented tests via a gradle command againts a newly created avd"
      end

      def self.details
        [
          "Instrumented tests need a emulator or real device to execute against.",
          "This action will check for a specific avd and created, wait for full boot,",
          "run gradle command, then deleted that avd on each run."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :avd_name,
                                       env_name: "AVD_NAME",
                                       description: "Name of the avd to be created",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :target_id,
                                       env_name: "TARGET_ID",
                                       description: "Target id of the avd to be created, get list of installed target by running command 'android list targets'",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :avd_options,
                                       env_name: "AVD_OPTIONS",
                                       description: "Other avd options in the form of a <option>=<value> list, i.e \"--scale 96dpi --dpi-device 160\"",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :avd_abi,
                                       env_name: "AVD_ABI",
                                       description: "The ABI to use for the AVD. The default is to auto-select the ABI if the platform has only one ABI for its system images",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :avd_tag,
                                       env_name: "AVD_TAG",
                                       description: "The sys-img tag to use for the AVD. The default is to auto-select if the platform has only one tag for its system images",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sdk_path,
                                       env_name: "SDK_PATH",
                                       description: "The path to your android sdk directory",
                                       is_string: true,
                                       default_value: ENV['SDK_PATH'],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :flags,
                                       env_name: "GRADLE_FLAGS",
                                       description: "All parameter flags you want to pass to the gradle command, e.g. `--exitcode --xml file.xml`",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :task,
                                       env_name: "GRADLE_TASK",
                                       description: "The gradle task you want to execute",
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.return_value
        "The output from the test execution."
      end

      def self.authors
        ["joshrlesch"]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
