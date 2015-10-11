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

      detect_platform # we can only do that *after* we have the scheme

      return config
    end

    # Is it an iOS device or a Mac?
    def self.detect_platform
      return if Scan.config[:destination]
      platform = Scan.project.mac? ? "OS X" : "iOS" # either `iOS` or `OS X`

      # TODO: here
      Scan.config[:destination] = "platform=iOS Simulator,name=iPhone 5s"
    end
  end
end
