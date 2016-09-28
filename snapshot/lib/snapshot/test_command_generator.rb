module Snapshot
  # Responsible for building the fully working xcodebuild command
  class TestCommandGenerator
    class << self
      def generate(device_type: nil)
        parts = prefix
        parts << "xcodebuild"
        parts += options
        parts += destination(device_type)
        parts += build_settings
        parts += actions
        parts += suffix
        parts += pipe

        parts
      end

      def prefix
        ["set -o pipefail &&"]
      end

      # Path to the project or workspace as parameter
      # This will also include the scheme (if given)
      # @return [Array] The array with all the components to join
      def project_path_array
        proj = Snapshot.project.xcodebuild_parameters
        return proj if proj.count > 0
        UI.user_error!("No project/workspace found")
      end

      def options
        config = Snapshot.config

        options = []
        options += project_path_array
        options << "-configuration '#{config[:configuration]}'" if config[:configuration]
        options << "-sdk '#{config[:sdk]}'" if config[:sdk]
        options << "-derivedDataPath '#{derived_data_path}'"

        options
      end

      def build_settings
        build_settings = []
        build_settings << "FASTLANE_SNAPSHOT=YES"

        build_settings
      end

      def actions
        actions = []
        actions << :clean if Snapshot.config[:clean]
        actions << :build # https://github.com/fastlane/snapshot/issues/246
        actions << :test

        actions
      end

      def suffix
        []
      end

      def pipe
        ["| tee #{xcodebuild_log_path.shellescape} | xcpretty #{Snapshot.config[:xcpretty_args]}"]
      end

      def find_device(device_name, os_version = Snapshot.config[:ios_version])
        # We might get this error message
        # > The requested device could not be found because multiple devices matched the request.
        #
        # This happens when you have multiple simulators for a given device type / iOS combination
        #   { platform:iOS Simulator, id:1685B071-AFB2-4DC1-BE29-8370BA4A6EBD, OS:9.0, name:iPhone 5 }
        #   { platform:iOS Simulator, id:A141F23B-96B3-491A-8949-813B376C28A7, OS:9.0, name:iPhone 5 }
        #
        simulators = FastlaneCore::DeviceManager.simulators
        # Sort devices with matching names by OS version, largest first, so that we can
        # pick the device with the newest OS in case an exact OS match is not available
        name_matches = simulators.find_all { |sim| sim.name.strip == device_name.strip }
                                 .sort_by { |sim| Gem::Version.new(sim.os_version) }
                                 .reverse
        name_matches.find { |sim| sim.os_version == os_version } || name_matches.first
      end

      def device_udid(device_name, os_version = Snapshot.config[:ios_version])
        device = find_device(device_name, os_version)

        device ? device.udid : nil
      end

      def destination(device_name)
        os = device_name =~ /^Apple TV/ ? "tvOS" : "iOS"
        os_version = Snapshot.config[:ios_version] || Snapshot::LatestOsVersion.version(os)

        device = find_device(device_name, os_version)
        if device.nil?
          UI.user_error!("No device found named '#{device_name}' for version '#{os_version}'")
          return
        elsif device.os_version != os_version
          UI.important("Using device named '#{device_name}' with version '#{device.os_version}' because no match was found for version '#{os_version}'")
        end
        value = "platform=#{os} Simulator,id=#{device.udid},OS=#{os_version}"

        return ["-destination '#{value}'"]
      end

      def xcodebuild_log_path
        file_name = "#{Snapshot.project.app_name}-#{Snapshot.config[:scheme]}.log"
        containing = File.expand_path(Snapshot.config[:buildlog_path])
        FileUtils.mkdir_p(containing)

        return File.join(containing, file_name)
      end

      def derived_data_path
        Snapshot.cache[:derived_data_path] ||= (Snapshot.config[:derived_data_path] || Dir.mktmpdir("snapshot_derived"))
      end
    end
  end
end
