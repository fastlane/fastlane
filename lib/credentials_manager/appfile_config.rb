module CredentialsManager
  # Access the content of the app file (e.g. app identifier and Apple ID)
  class AppfileConfig

    def self.try_fetch_value(key)
      if self.default_path
        return (self.new.data[key] rescue nil)
      end
      nil
    end

    def self.default_path
      ["./fastlane/Appfile", "./Appfile"].each do |current|
        return current if File.exists?current
      end
      nil
    end

    def initialize(path = nil)
      path ||= self.class.default_path      

      raise "Could not find Appfile at path '#{path}'".red unless File.exists?(path)

      full_path = File.expand_path(path)
      Dir.chdir(File.expand_path('..', path)) do
        eval(File.read(full_path))
      end

      # If necessary override per lane configuration
      blocks[ENV["FASTLANE_LANE_NAME"].to_sym].call if blocks[ENV["FASTLANE_LANE_NAME"].to_sym]
    end

    def blocks
      @blocks ||= {}
    end

    def data
      @data ||= {}
    end

    # Setters

    def app_identifier(value)
      value ||= yield if block_given?
      data[:app_identifier] = value if value
    end

    def apple_id(value)
      value ||= yield if block_given?
      data[:apple_id] = value if value
    end

    def team_id(value)
      value ||= yield if block_given?
      data[:team_id] = value if value
    end

    def team_name(value)
      value ||= yield if block_given?
      data[:team_name] = value if value
    end

    # Override Appfile configuration for a specific lane.
    #
    # lane_name  - Symbol representing a lane name.
    # block - Block to execute to override configuration values.
    #
    # Discussion If received lane name does not match the lane name available as environment variable, no changes will
    #             be applied.
    def for_lane(lane_name, &block)
      raise "Configuration for lane '#{lane_name}' was defined multiple times!".red if blocks[lane_name]
      blocks[lane_name] = block
    end
  end
end