require_relative 'test_command_generator_base'
require_relative 'module'
require_relative 'latest_os_version'

module Snapshot
  # Responsible for building the fully working xcodebuild command
  # This TestCommandGenerator supports Xcode 8's `xcodebuild` requirements
  # It is its own object, as the logic differs for how we want to handle
  # creating `xcodebuild` commands for Xcode 9 (see test_command_generator.rb)
  class TestCommandGeneratorXcode8 < TestCommandGeneratorBase
    class << self
      def generate(device_type: nil, language: nil, locale: nil)
        parts = prefix
        parts << "xcodebuild"
        parts += options(language, locale)
        parts += destination(device_type)
        parts += build_settings(language, locale)
        parts += actions
        parts += suffix
        parts += pipe(device_type, language, locale)

        return parts
      end

      def pipe(device_type, language, locale)
        log_path = xcodebuild_log_path(device_type: device_type, language: language, locale: locale)
        pipe = ["| tee #{log_path.shellescape}"]
        pipe << "| xcpretty #{Snapshot.config[:xcpretty_args]}"
        pipe << "> /dev/null" if Snapshot.config[:suppress_xcode_output]
        return pipe
      end

      def destination(device_name)
        # on Mac we will always run on host machine, so should specify only platform
        return ["-destination 'platform=macOS'"] if device_name =~ /^Mac/

        # if device_name is nil, use the config and get all devices
        os = device_name =~ /^Apple TV/ ? "tvOS" : "iOS"
        os_version = Snapshot.config[:ios_version] || Snapshot::LatestOsVersion.version(os)

        device = find_device(device_name, os_version)
        if device.nil?
          UI.user_error!("No device found named '#{device_name}' for version '#{os_version}'")
        elsif device.os_version != os_version
          UI.important("Using device named '#{device_name}' with version '#{device.os_version}' because no match was found for version '#{os_version}'")
        end
        value = "platform=#{os} Simulator,id=#{device.udid},OS=#{device.os_version}"

        return ["-destination '#{value}'"]
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
