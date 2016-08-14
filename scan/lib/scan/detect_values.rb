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

      default_derived_data

      return config
    end

    def self.default_derived_data
      return unless Scan.config[:derived_data_path].to_s.empty?
      default_path = Scan.project.build_settings(key: "BUILT_PRODUCTS_DIR")
      # => /Users/.../Library/Developer/Xcode/DerivedData/app-bqrfaojicpsqnoglloisfftjhksc/Build/Products/Release-iphoneos
      # We got 3 folders up to point to ".../DerivedData/app-[random_chars]/"
      default_path = File.expand_path("../../..", default_path)
      UI.verbose("Detected derived data path '#{default_path}'")
      Scan.config[:derived_data_path] = default_path
    end

    def self.filter_simulators(simulators, deployment_target)
      # Select only simulators that are greater than or equal to the version of our deployment target
      deployment_target_version = Gem::Version.new(deployment_target)
      simulators.select do |s|
        sim_version = Gem::Version.new(s.ios_version)
        (sim_version >= deployment_target_version)
      end
    end

    def self.regular_expression_for_split_on_whitespace_followed_by_parenthesized_version
      %r{
        \s # a whitespace character
        (?= # followed by — using lookahead
        \( # open parenthesis
        [\d\.]+ # our version — one or more digits or full stops
        \) # close parenthesis
        $ # end of line
        ) # end of lookahead
      }
    end

    def self.default_device_ios
      # An iPhone 5s is a reasonably small and useful default for tests
      default_device('iOS', 'IPHONEOS_DEPLOYMENT_TARGET', 'iPhone 5s', nil)
    end

    def self.default_device_tvos
      default_device('tvOS', 'TVOS_DEPLOYMENT_TARGET', 'Apple TV 1080p', 'TV')
    end

    def self.default_device(requested_os_type, deployment_target_key, default_device_name, simulator_type_descriptor)
      require 'set'

      # Select only simulators that are greater than or equal to the version of our deployment target
      simulators = filter_simulators(
        FastlaneCore::DeviceManager.simulators(requested_os_type),
        Scan.project.build_settings(key: deployment_target_key)
      )

      matches = lambda do
        devices = Scan.config[:devices] || Array(Scan.config[:device]) # important to use Array(nil) for when the value is nil

        devices.inject(
          Set.new # of simulators
        ) { |set, device_string|
          pieces = device_string.split(regular_expression_for_split_on_whitespace_followed_by_parenthesized_version)

          set + (
            if pieces.count == 0
              [] # empty array
            elsif pieces.count == 1
              simulators
            else # pieces.count == 2 — mathematically, because of the ‘end of line’ part of our regular expression
              filter_simulators(simulators, pieces[1].tr('()', ''))
            end
          ).select { |sim| sim.name == pieces.first }
          .tap { |array| UI.error("Ignoring '#{device_string}', couldn’t find matching simulator") if array.empty? }
        }.to_a
      end

      default = lambda do
        UI.error("Couldn't find any matching simulators for '#{devices}' - falling back to default simulator")
        Array(
          simulators.detect { |d| d.name == default_device_name } || simulators.first
        ).tap do |array|
          UI.user_error!(
            ['No', simulator_type_descriptor, 'simulators found on local machine'].reject(&:nil?).join(' ')
          ) if array.empty?
        end
      end

      # grab the first unempty evaluated array
      Scan.devices = [matches, default].lazy.flat_map { |x|
        arr = x.call
        arr unless arr.empty?
      }.first
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
