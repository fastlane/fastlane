module Fastlane
  module Helper
    class AdbDevice
      attr_accessor :serial

      def initialize(serial: nil)
        self.serial = serial
      end
    end

    class AdbHelper
      # Path to the adb binary
      attr_accessor :adb_path

      # Path to the adb binary
      attr_accessor :adb_host

      # All available devices
      attr_accessor :devices

      def initialize(adb_path: nil, adb_host: nil)
        android_home = ENV['ANDROID_HOME'] || ENV['ANDROID_SDK_ROOT'] || ENV['ANDROID_SDK']
        if (adb_path.nil? || adb_path == "adb") && android_home
          adb_path = File.join(android_home, "platform-tools", "adb")
        end

        self.adb_path = Helper.get_executable_path(File.expand_path(adb_path))
        self.adb_host = adb_host
      end

      def host_option
        return self.adb_host ? "-H #{adb_host}" : nil
      end

      # Run a certain action
      def trigger(command: nil, serial: nil)
        android_serial = serial != "" ? "ANDROID_SERIAL=#{serial}" : nil
        command = [android_serial, adb_path.shellescape, host_option, command].compact.join(" ").strip
        Action.sh(command)
      end

      def device_avalaible?(serial)
        UI.deprecated("Please use `device_available?` instead... This will be removed in a future version of fastlane")
        device_available?(serial)
      end

      def device_available?(serial)
        load_all_devices
        return devices.map(&:serial).include?(serial)
      end

      def load_all_devices
        self.devices = []

        command = [adb_path.shellescape, host_option, "devices -l"].compact.join(" ")
        output = Actions.sh(command, log: false)
        output.split("\n").each do |line|
          if (result = line.match(/^(\S+)(\s+)(device )/))
            self.devices << AdbDevice.new(serial: result[1])
          end
        end
        self.devices
      end
    end
  end
end
