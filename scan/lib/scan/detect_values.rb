module Scan
  # This class detects all kinds of default values
  class DetectValues
    # This is needed as these are more complex default values
    # Returns the finished config object
    def self.set_additional_default_values
      config = Scan.config

      # First, try loading the Scanfile from the current directory
      config.load_configuration_file(Scan.scanfile_name)

      # Detect the project
      FastlaneCore::Project.detect_projects(config)
      Scan.project = FastlaneCore::Project.new(config)

      # Go into the project's folder, as there might be a Snapfile there
      Dir.chdir(File.expand_path("..", Scan.project.path)) do
        config.load_configuration_file(Scan.scanfile_name)
      end

      Scan.project.select_scheme

      default_device_ios if Scan.project.ios?
      default_device_tvos if Scan.project.tvos?
      detect_destination

      return config
    end

    def self.filter_simulators(simulators, deployment_target)
      # Filter out any simulators that are not the same major and minor version of our deployment target
      deployment_target_version = Gem::Version.new(deployment_target)
      simulators.select do |s|
        sim_version = Gem::Version.new(s.ios_version)
        (sim_version >= deployment_target_version)
      end
    end

    def self.default_device_ios
      devices = Scan.config[:devices] || Array(Scan.config[:device]) # important to use Array(nil) for when the value is nil
      found_devices = []

      if devices.any?
        # Optionally, we only do this if the user specified a custom device or an array of devices
        devices.each do |device|
          lookup_device = device.to_s.strip.tr('()', '') # Remove parenthesis

          found = FastlaneCore::Simulator.all.detect do |d|
            (d.name + " " + d.ios_version).include? lookup_device
          end

          if found
            found_devices.push(found)
          else
            UI.error("Ignoring '#{device}', couldn't find matching simulator")
          end
        end

        if found_devices.any?
          Scan.devices = found_devices
          return
        else
          UI.error("Couldn't find any matching simulators for '#{devices}' - falling back to default simulator")
        end
      end

      sims = FastlaneCore::Simulator.all
      xcode_target = Scan.project.build_settings(key: "IPHONEOS_DEPLOYMENT_TARGET")
      sims = filter_simulators(sims, xcode_target)

      # An iPhone 5s is reasonable small and useful for tests
      found = sims.detect { |d| d.name == "iPhone 5s" }
      found ||= sims.first # anything is better than nothing

      if found
        Scan.devices = [found]
      else
        UI.user_error!("No simulators found on local machine")
      end
    end

    def self.default_device_tvos
      devices = Scan.config[:devices] || Array(Scan.config[:device]) # important to use Array(nil) for when the value is nil
      found_devices = []

      if devices.any?
        # Optionally, we only do this if the user specified a custom device or an array of devices
        devices.each do |device|
          lookup_device = device.to_s.strip.tr('()', '') # Remove parenthesis

          found = FastlaneCore::SimulatorTV.all.detect do |d|
            (d.name + " " + d.os_version).include? lookup_device
          end

          if found
            found_devices.push(found)
          else
            UI.error("Ignoring '#{device}', couldn't find matching simulator")
          end
        end

        if found_devices.any?
          Scan.devices = found_devices
          return
        else
          UI.error("Couldn't find any matching simulators for '#{devices}' - falling back to default simulator")
        end
      end

      sims = FastlaneCore::SimulatorTV.all
      xcode_target = Scan.project.build_settings(key: "TVOS_DEPLOYMENT_TARGET")
      sims = filter_simulators(sims, xcode_target)

      # Apple TV 1080p is useful for tests
      found = sims.detect { |d| d.name == "Apple TV 1080p" }
      found ||= sims.first # anything is better than nothing

      if found
        Scan.devices = [found]
      else
        UI.user_error!("No TV simulators found on the local machine")
      end
    end

    def self.min_xcode8?
      Helper.xcode_version.split(".").first.to_i >= 8
    end

    # Is it an iOS, a tvOS or a macOS device?
    def self.detect_destination
      if Scan.config[:destination]
        UI.important("It's not recommended to set the `destination` value directly")
        UI.important("Instead use the other options available in `scan --help`")
        UI.important("Using your value '#{Scan.config[:destination]}' for now")
        UI.important("because I trust you know what you're doing...")
        return
      end

      # building up the destination now
      if Scan.project.ios?
        Scan.config[:destination] = Scan.devices.map { |d| "platform=iOS Simulator,id=#{d.udid}" }
      elsif Scan.project.tvos?
        Scan.config[:destination] = Scan.devices.map { |d| "platform=tvOS Simulator,id=#{d.udid}" }
      else
        Scan.config[:destination] = min_xcode8? ? ["platform=macOS"] : ["platform=OS X"]
      end
    end
  end
end
