require 'snapshot/test_command_generator_base'

module Snapshot
  # Responsible for building the fully working xcodebuild command
  class TestCommandGenerator < TestCommandGeneratorBase
    class << self
      def generate(device_type: nil, language: nil, locale: nil)
        parts = prefix
        parts << "xcodebuild"
        parts += options
        parts += destination(device_type)
        parts += build_settings
        parts += actions
        parts += suffix
        parts += pipe(device_type, language, locale)

        return parts
      end

      def pipe(device_type, language, locale)
        log_path = xcodebuild_log_path(device_type: device_type, language: language, locale: locale)
        return ["| tee #{log_path.shellescape} | xcpretty #{Snapshot.config[:xcpretty_args]}"]
      end

      def destination(device_name)
        # on Mac we will always run on host machine, so should specify only platform
        return ["-destination 'platform=macOS'"] if device_name =~ /^Mac/

        # if device_name is nil, use the config and get all devices
        os = device_name =~ /^Apple TV/ ? "tvOS" : "iOS"
        os_version = Snapshot.config[:ios_version] || Snapshot::LatestOsVersion.version(os)

        destinations = Snapshot.config[:devices].map do |d|
          device = find_device(d, os_version)
          UI.user_error!("No device found named '#{d}' for version '#{os_version}'") if device.nil?
          "-destination 'platform=#{os} Simulator,name=#{device.name},OS=#{os_version}'"
        end

        return [destinations.join(' ')]
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
