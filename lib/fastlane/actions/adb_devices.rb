module Fastlane
  module Actions
    module SharedValues
    end

    class AdbDevicesAction < Action
      def self.run(params)
        adb = Helper::AdbHelper.new(adb_path: params[:adb_path])
        result = adb.load_all_devices
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get an Array of Connected android device serials"
      end

      def self.details
        [
          "fetches device list via adb"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :adb_path,
                                       env_name: "FL_ADB_PATH",
                                       description: "The path to your `adb` binary",
                                       is_string: true,
                                       optional: true,
                                       default_value: "adb"
                                      )
        ]
      end

      def self.output
      end

      def self.return_value
        "Array of devices"
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
