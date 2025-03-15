require_relative 'test_command_generator_base'
require_relative 'latest_os_version'

module Snapshot
  # Responsible for building the fully working xcodebuild command
  # Xcode 9 introduced the ability to run tests in parallel on multiple simulators
  # This TestCommandGenerator constructs the appropriate `xcodebuild` command
  # to be used for executing simultaneous tests
  class TestCommandGenerator < TestCommandGeneratorBase
    class << self
      def generate(devices: nil, language: nil, locale: nil, log_path: nil)
        parts = prefix
        parts << "xcodebuild"
        parts += options(language, locale)
        parts += destination(devices)
        parts += build_settings(language, locale)
        parts += actions
        parts += suffix
        parts += pipe(log_path: log_path)

        return parts
      end

      def pipe(log_path: nil)
        tee_command = ['tee']
        tee_command << '-a' if log_path && File.exist?(log_path)
        tee_command << log_path.shellescape if log_path

        pipe = ["| #{tee_command.join(' ')}"]

        formatter = Snapshot.config[:xcodebuild_formatter].chomp
        options = legacy_xcpretty_options

        if Snapshot.config[:disable_xcpretty] || formatter == ''
          UI.verbose("Not using an xcodebuild formatter")
        elsif !options.empty?
          UI.important("Detected legacy xcpretty being used, so formatting with xcpretty")
          UI.important("Option(s) used: #{options.join(', ')}")
          pipe += pipe_xcpretty
        elsif formatter == 'xcpretty'
          pipe += pipe_xcpretty
        elsif formatter == 'xcbeautify'
          pipe += pipe_xcbeautify
        else
          pipe << "| #{formatter}"
        end

        pipe
      end

      def pipe_xcbeautify
        pipe = ['| xcbeautify']

        if FastlaneCore::Helper.colors_disabled?
          pipe << '--disable-colored-output'
        end

        return pipe
      end

      def legacy_xcpretty_options
        options = []
        options << "xcpretty_args" if Snapshot.config[:xcpretty_args]
        return options
      end

      def pipe_xcpretty
        pipe = []
        xcpretty = "xcpretty #{Snapshot.config[:xcpretty_args]}"
        xcpretty << "--no-color" if Helper.colors_disabled?
        pipe << "| #{xcpretty}"
        pipe << "> /dev/null" if Snapshot.config[:suppress_xcode_output]
        return pipe
      end

      def destination(devices)
        unless verify_devices_share_os(devices)
          UI.user_error!('All devices provided to snapshot should run the same operating system')
        end
        # on Mac we will always run on host machine, so should specify only platform
        return ["-destination 'platform=macOS'"] if devices.first.to_s =~ /^Mac/

        case devices.first.to_s
        when /^Apple TV/
          os = 'tvOS'
        when /^Apple Watch/
          os = 'watchOS'
        else
          os = 'iOS'
        end

        os_version = Snapshot.config[:ios_version] || Snapshot::LatestOsVersion.version(os)

        destinations = devices.map do |d|
          device = find_device(d, os_version)
          if device.nil?
            UI.user_error!("No device found named '#{d}' for version '#{os_version}'") if device.nil?
          elsif device.os_version != os_version
            UI.important("Using device named '#{device.name}' with version '#{device.os_version}' because no match was found for version '#{os_version}'")
          end
          "-destination 'platform=#{os} Simulator,name=#{device.name},OS=#{device.os_version}'"
        end

        return [destinations.join(' ')]
      end

      def verify_devices_share_os(device_names)
        # Get device types based off of device name
        devices = get_device_type_with_simctl(device_names)

        # Check each device to see if it is an iOS device
        all_ios = devices.map do |device|
          device = device.downcase
          device.include?('iphone') || device.include?('ipad') || device.include?('ipod')
        end
        # Return true if all devices are iOS devices
        return true unless all_ios.include?(false)

        all_tvos = devices.map do |device|
          device = device.downcase
          device.include?('apple tv')
        end
        # Return true if all devices are tvOS devices
        return true unless all_tvos.include?(false)

        all_watchos = devices.map do |device|
          device = device.downcase
          device.include?('apple watch')
        end
        # Return true if all devices are watchOS devices
        return true unless all_watchos.include?(false)

        # There should only be more than 1 device type if
        # it is iOS or tvOS, therefore, if there is more than 1
        # device in the array, and they are not all iOS or tvOS
        # as checked above, that would imply that this is a mixed bag
        return devices.count == 1
      end

      private

      def get_device_type_with_simctl(device_names)
        return device_names if Helper.test?

        require("simctl")

        # Gets actual simctl device type from device name
        return device_names.map do |device_name|
          device = SimCtl.device(name: device_name)
          if device
            device.devicetype.name
          end
        end.compact
      end
    end
  end
end
