module Snapshot
  class ResetSimulators
    def self.clear_everything!(ios_version)
      # Taken from https://gist.github.com/cabeca/cbaacbeb6a1cc4683aa5

      # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      # !! Warning: This script will remove all your existing simulators !!
      # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      sure = true if ENV["SNAPSHOT_FORCE_DELETE"]
      sure = agree("Are you sure? All your simulators will be DELETED and new ones will be created! (y/n)".red, true) unless sure

      raise "User cancelled action" unless sure
       
      device_types_output = `xcrun simctl list devicetypes`
      device_types = device_types_output.scan /(.*) \((.*)\)/
       
      devices_output = `xcrun simctl list devices`.split("\n")

      devices_output.each do |line|
        device = line.match(/\s+([\w\s]+)\(([\w\-]+)\)/)
        if device and device.length == 3
          name = device[1].strip
          id = device[2]
          puts "Removing device #{name} (#{id})"
          `xcrun simctl delete #{id}`
        end
      end

      # device_types
      #  ["iPhone 5", "com.apple.CoreSimulator.SimDeviceType.iPhone-5"],
      #  ["iPhone 5s", "com.apple.CoreSimulator.SimDeviceType.iPhone-5s"],
      #  ["iPhone 6", "com.apple.CoreSimulator.SimDeviceType.iPhone-6"],
      device_types.each do |device_type|
        next if device_type.first.include?"Watch" # we don't want to deal with the Watch right now

        puts "Creating #{device_type} for iOS version #{ios_version}"
        command = "xcrun simctl create '#{device_type[0]}' #{device_type[1]} #{ios_version}"
        command_output = `#{command}`
      end
    end
  end
end