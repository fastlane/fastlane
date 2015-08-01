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
      # WRAPPER_NAME: Example.app
      # WRAPPER_SUFFIX: .app
      build_settings("WRAPPER_NAME").gsub(build_settings("WRAPPER_SUFFIX"), "")
    end

    #####################################################
    # @!group Raw Access
    #####################################################


    # Get the build settings for our project
    # this is used to properly get the DerivedData folder
    # @param [String] The key of which we want the value for (e.g. "PRODUCT_NAME")
    def build_settings(key)
      unless @build_settings
        # We also need to pass the workspace and scheme to this command
        options = BuildCommandGenerator.options
        command = "xcrun xcodebuild -showBuildSettings #{options.join(' ')}" 
        Helper.log.info command.yellow
        @build_settings = `#{command}`
      end

      begin
        result = @build_settings.split("\n").find { |c| c.include?key }
        result.split(" = ").last
      rescue => ex
        Helper.log.error caller.join("\n\t")
        Helper.log.error "Could not fetch #{key} from project file: #{ex}"
      end
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