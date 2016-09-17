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

      # All available devices
      attr_accessor :devices

      def initialize(adb_path: nil)
        self.adb_path = adb_path
      end

      # Run a certain action
      def trigger(command: nil, serial: nil)
        android_serial = serial != "" ? "ANDROID_SERIAL=#{serial}" : nil
        command = [android_serial, adb_path, command].join(" ")
        Action.sh(command)
      end

      def device_avalaible?(serial)
        load_all_devices
        return devices.map(&:serial).include?(serial)
      end

      def load_all_devices
        self.devices = []

        command = [adb_path, "devices"].join(" ")
        output = Actions.sh(command, log: false)
        output.split("\n").each do |line|
          if (result = line.match(/(.*)\tdevice$/))
            self.devices << AdbDevice.new(serial: result[1])
          end
        end
        self.devices
      end
    end
  end
end
