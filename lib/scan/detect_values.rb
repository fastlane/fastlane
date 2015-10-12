module Scan
  # This class detects all kinds of default values
  class DetectValues
    # This is needed as these are more complex default values
    # Returns the finished config object
    def self.set_additional_default_values
      config = Scan.config

      FastlaneCore::Project.detect_projects(config)
      Scan.project = FastlaneCore::Project.new(config)

      # Go into the project's folder
      Dir.chdir(File.expand_path("..", Scan.project.path)) do
        config.load_configuration_file(Scan.scanfile_name)
      end

      Scan.project.select_scheme

      default_device unless config[:device]
      detect_destination

      return config
    end

    def self.default_device
      config = Scan.config

      # An iPhone 5s is reasonable small and useful for tests
      found = FastlaneCore::Simulator.all.find { |d| d.name == "iPhone 5s" }
      found ||= FastlaneCore::Simulator.all.first # anything is better than nothing

      config[:device] = found.name
      raise "No simulators found".red unless config[:device]
    end

    # Is it an iOS device or a Mac?
    def self.detect_destination
      if Scan.config[:destination]
        Helper.log.info "It's not recommended to set the `destination` value directly".yellow
        Helper.log.info "Instead use the other options available in `scan --help`".yellow
        Helper.log.info "Using your value '#{Scan.config[:destination]}' for now".yellow
        Helper.log.info "because I trust you know what you're doing...".yellow
        return
      end

      # building up the destination now
      Scan.config[:destination] = "platform=iOS Simulator,name=#{Scan.config[:device]}"
      require 'pry'
      binding.pry
    end
  end
end
