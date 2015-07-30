module Attach
  # Represents the Xcode project/workspace
  class Project
    # Path to the project/workspace
    attr_accessor :path

    attr_accessor :is_workspace

    def initialize(options)
      self.path = options[:workspace] || options[:project]
      self.is_workspace = (options[:workspace].to_s.length > 0)
    end

    # Get all available schemes in an array
    def schemes
      results = []
      output = raw_info.split("Schemes:").last.split(":").first
      output.split("\n").each do |current|
        current = current.strip
        results << current if current.length > 0
      end

      results
    end

    def app_name
      build_settings["App Name"]
    end

    #####################################################
    # @!group Raw Access
    #####################################################


    # Get the build settings for our project
    # this is used to properly get the DerivedData folder
    def build_settings
      return @build_settings if @build_settings 

      # We also need to pass the workspace and scheme to this command
      # options = BuildCommandGenerator.new.options
      # command = "xcrun xcodebuild -showBuildSettings #{options.join(' ')}" 
      # Helper.log.info command.yellow
      # require 'pry'; binding.pry
      # data = `#{command}`
      # TODO
    end

    def raw_info
      # e.g.
      # Information about project "Example":
      #     Targets:
      #         Example
      #         ExampleUITests
      #
      #     Build Configurations:
      #         Debug
      #         Release
      #
      #     If no build configuration is specified and -scheme is not passed then "Release" is used.
      #
      #     Schemes:
      #         Example
      #         ExampleUITests
      @raw ||= `xcrun xcodebuild -list`
    end
  end
end