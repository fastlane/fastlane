module Fastlane
  module Actions
    module SharedValues
    end

    class AdbDevicesAction < Action
      def self.run(params)
        adb_path = params[:adb_path]
        if adb_path == "adb" && params[:android_home]
          adb_path = Pathname.new(params[:android_home]).join("platform-tools/adb").to_s
        end
        adb = Helper::AdbHelper.new(adb_path: adb_path)
        result = adb.load_all_devices
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get an array of Connected android device serials"
      end

      def self.details
        [
          "Fetches device list via adb, e.g. run an adb command on all connected devices."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :android_home,
                                       optional: true,
                                       default_value: ENV['ANDROID_HOME'] || ENV['ANDROID_SDK_ROOT'] || ENV['ANDROID_SDK'],
                                       default_value_dynamic: true,
                                       description: "Path to the root of your Android SDK installation, e.g. ~/tools/android-sdk-macosx"),
          FastlaneCore::ConfigItem.new(key: :adb_path,
                                       env_name: "FL_ADB_PATH",
                                       description: "The path to your `adb` binary",
                                       is_string: true,
                                       optional: true,
                                       default_value: "adb")
        ]
      end

      def self.output
      end

      def self.example_code
        [
          'adb_devices.each do |device|
            model = adb(command: "shell getprop ro.product.model",
                        serial: device.serial).strip

            puts "Model #{model} is connected"
          end'
        ]
      end

      def self.sample_return_value
        []
      end

      def self.category
        :misc
      end

      def self.return_value
        "Returns an array of all currently connected android devices"
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
