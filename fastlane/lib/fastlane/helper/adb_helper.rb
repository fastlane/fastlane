module Fastlane
  module Helper
    class AdbDevice
      attr_accessor :serial, :name

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
        android_home = ENV['ANDROID_HOME'] || ENV['ANDROID_SDK_ROOT'] || ENV['ANDROID_SDK']
        if (adb_path.nil? || adb_path == "adb") && android_home
          adb_path = Pathname.new(android_home).join("platform-tools/adb").to_s
        end
        self.adb_path = adb_path
      end

      # Run a certain action
      def trigger(command: nil, serial: nil)
        android_serial = serial != "" ? "ANDROID_SERIAL=#{serial}" : nil
        command = [android_serial, adb_path, command].join(" ")
        Action.sh(command)
      end

      def device_avalaible?(serial, load_names = false)
        load_all_devices(load_names)
        return devices.map(&:serial).include?(serial)
      end

      def load_all_devices(load_names = false)
        self.devices = []

        command = [adb_path, "devices"].join(" ")
        output = Actions.sh(command, log: false)
        output.split("\n").each do |line|
          if (result = line.match(/^(\S+)(\s+)(?=device)/))
            self.devices << AdbDevice.new(serial: result[1])
          end
        end

        # Checks if telnet is intalled
        # Display message to user to install it to get full value
        has_telnet_installed = has_brew_tool!('telnet')

        # Iterates devices to load name from telnet for emulators
        # and adb from actual devices
        if load_names &&

           self.devices
          self.devices.each do |device|
            if device.serial.include?('emulator-')
              load_name_from_telnet(device) if has_telnet_installed
            else
              load_name_from_adb(device)
            end
          end
        end
      end

      private

      def load_name_from_telnet(device)
        # Gets port to connect to via telnet
        port = device.serial.gsub('emulator-', '')

        # Pipes `avd name` to telnet, sleeps to get output, and exits
        # Runs empty echo after telnet to make Actions.sh happy
        output = Actions.sh(
          "sleep1; (echo 'avd name'; sleep 1; echo 'exit 0') | telnet localhost #{port}; echo ''",
          log: false
        )

        # Gets emulator name from between the "OK"s
        regex = /\sOK\s(.*?)\sOK\b/m
        device.name = output.slice(regex, 1)
      end

      def load_name_from_adb(device)
        device.name = trigger(command: "shell getprop ro.product.model", serial: device.serial).strip
      end

      def has_brew_tool!(tool)
        unless `which #{tool}`.include?(tool.to_s)
          UI.error('#############################################################')
          UI.error("# You have to install the #{tool} to use load_name")
          UI.error("# Install it using 'brew update && brew install #{tool}'")
          UI.error("# If you don't have homebrew: http://brew.sh")
          UI.error('#############################################################')
          return false
        end
        return true
      end
    end
  end
end
