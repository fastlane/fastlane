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
       
      devices_output = `xcrun simctl list devices`
      devices = devices_output.scan /\s\s\s\s(.*) \(([^)]+)\) (.*)/

      devices.each do |device|
        puts "Removing device #{device[0]} (#{device[1]})"
        `xcrun simctl delete #{device[1]}`
      end

      device_types.each do |device_type|
        puts "Creating #{device_type} for iOS version #{ios_version}"
        command = "xcrun simctl create '#{device_type[0]}' #{device_type[1]} #{ios_version}"
        command_output = `#{command}`
        sleep 0.5
      end
    end
  end
end