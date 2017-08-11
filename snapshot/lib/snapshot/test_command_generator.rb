require 'snapshot/test_command_generator_base'

module Snapshot
  # Responsible for building the fully working xcodebuild command
  class TestCommandGenerator < TestCommandGeneratorBase
    class << self
      def generate(devices: nil, language: nil, locale: nil)
        parts = prefix
        parts << "xcodebuild"
        parts += options
        parts += destination(devices)
        parts += build_settings
        parts += actions
        parts += suffix
        # parts += pipe(devices, language, locale)

        return parts
      end

      def pipe(device_type, language, locale)
        log_path = xcodebuild_log_path(device_type: device_type, language: language, locale: locale)
        return ["| tee #{log_path.shellescape} | xcpretty #{Snapshot.config[:xcpretty_args]}"]
      end

      def destination(devices)
        # on Mac we will always run on host machine, so should specify only platform
        return ["-destination 'platform=macOS'"] if devices.first.to_s =~ /^Mac/

        os = devices.first.to_s =~ /^Apple TV/ ? "tvOS" : "iOS"

        unless verify_devices_share_os(devices)
          UI.user_error!('All devices provided to snapshot should run the same operating system')
        end

        os_version = Snapshot.config[:ios_version] || Snapshot::LatestOsVersion.version(os)

        destinations = devices.map do |d|
          device = find_device(d, os_version)
          UI.user_error!("No device found named '#{d}' for version '#{os_version}'") if device.nil?
          "-destination 'platform=#{os} Simulator,name=#{device.name},OS=#{os_version}'"
        end

        return [destinations.join(' ')]
      end

      def verify_devices_share_os(devices)
        # Check each device to see if it is an iOS device
        all_iOS = devices.map do |device|
          device.start_with?('iPhone') || device.start_with?('iPad')
        end
        # Return true if all devices are iOS devices
        return true unless all_iOS.include?(false)
        # There should only be more than 1 device type if
        # it is iOS, therefore, if there is more than 1
        # device in the array, and they are not all iOS
        # as checked above, that would imply that this is a mixed bag
        return devices.count == 1
      end

      def xcodebuild_log_path(device_type: nil, language: nil, locale: nil)
        name_components = [Snapshot.project.app_name, Snapshot.config[:scheme]]

        if Snapshot.config[:namespace_log_files]
          name_components << device_type if device_type
          name_components << language if language
          name_components << locale if locale
        end

        file_name = "#{name_components.join('-')}.log"

        containing = File.expand_path(Snapshot.config[:buildlog_path])
        FileUtils.mkdir_p(containing)

        return File.join(containing, file_name)
      end
    end
  end
end
