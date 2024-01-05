module Fastlane
  module Actions
    module SharedValues
    end

    class AdbAction < Action
      def self.run(params)
        adb = Helper::AdbHelper.new(adb_path: params[:adb_path])
        result = adb.trigger(command: params[:command], serial: params[:serial])
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Run ADB Actions"
      end

      def self.details
        "see adb --help for more details"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :serial,
                                       env_name: "FL_ANDROID_SERIAL",
                                       description: "Android serial of the device to use for this command",
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :command,
                                       env_name: "FL_ADB_COMMAND",
                                       description: "All commands you want to pass to the adb command, e.g. `kill-server`",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :adb_path,
                                       env_name: "FL_ADB_PATH",
                                       optional: true,
                                       description: "The path to your `adb` binary (can be left blank if the ANDROID_SDK_ROOT, ANDROID_HOME or ANDROID_SDK environment variable is set)",
                                       default_value: "adb")
        ]
      end

      def self.output
      end

      def self.category
        :building
      end

      def self.example_code
        [
          'adb(
            command: "shell ls"
          )'
        ]
      end

      def self.return_value
        "The output of the adb command"
      end

      def self.return_type
        :string
      end

      def self.authors
        ["hjanuschka"]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
