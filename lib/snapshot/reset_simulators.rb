module Snapshot
  class ResetSimulators
    def self.clear_everything!(ios_versions)
      # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      # !! Warning: This script will remove all your existing simulators !!
      # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      sure = true if ENV["SNAPSHOT_FORCE_DELETE"]
      sure = agree("Are you sure? All your simulators will be DELETED and new ones will be created! (y/n)".red, true) unless sure
      raise "User cancelled action" unless sure

      all_devices = `xcrun simctl list devices`
      # == Devices ==
      # -- iOS 9.0 --
      #   iPhone 4s (32246EBC-33B0-47F9-B7BB-5C23C550DF29) (Shutdown)
      #   iPhone 5 (4B56C101-6B95-43D1-9485-3FBA0E127FFA) (Shutdown)
      #   iPhone 5s (6379C204-E82A-4FBD-8A22-6A01C7791D62) (Shutdown)
      # -- Unavailable: com.apple.CoreSimulator.SimRuntime.iOS-8-4 --
      #   iPhone 4s (FE9D6F85-1C51-4FE6-8597-FCAB5286B869) (Shutdown) (unavailable, runtime profile not found)

      all_devices.split("\n").each do |line|
        parsed = line.match(/\s+([\w\s]+)\s\(([\w\-]+)\)/) || []
        next unless parsed.length == 3 # we don't care about those headers
        _, name, id = parsed.to_a
        puts "Removing device #{name} (#{id})"
        `xcrun simctl delete #{id}`
      end

      all_device_types = `xcrun simctl list devicetypes`.scan(/(.*)\s\((.*)\)/)
      # == Device Types ==
      # iPhone 4s (com.apple.CoreSimulator.SimDeviceType.iPhone-4s)
      # iPhone 5 (com.apple.CoreSimulator.SimDeviceType.iPhone-5)
      # iPhone 5s (com.apple.CoreSimulator.SimDeviceType.iPhone-5s)
      # iPhone 6 (com.apple.CoreSimulator.SimDeviceType.iPhone-6)
      all_device_types.each do |device_type|
        next if device_type.join(' ').include? "Watch" # we don't want to deal with the Watch right now

        ios_versions.each do |ios_version|
          puts "Creating #{device_type} for iOS version #{ios_version}"
          `xcrun simctl create '#{device_type[0]}' #{device_type[1]} #{ios_version}`
        end
      end
    end
  end
end
