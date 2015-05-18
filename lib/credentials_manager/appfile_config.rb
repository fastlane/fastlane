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
      #
      # Appfile can specify different rules per:
      # - Platform
      # - Lane
      #
      # It is forbidden to specify multiple configuration for the same platform. It will raise an exception.

      # Plaform specified.
      if for_platform_configuration?(blocks)
        blocks[ENV["FASTLANE_PLATFORM_NAME"]].call
        inner_block = blocks[ENV["FASTLANE_PLATFORM_NAME"]]
        if for_lane_configuration?(inner_block)
          # .. Lane specified
          inner_block[ENV["FASTLANE_LANE_NAME"]].call
        end
      else
        # Platform not specified
        if for_lane_configuration?(blocks)
          # .. Lane specified
          blocks[ENV["FASTLANE_LANE_NAME"]].call
        end
      end
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
      raise "Configuration for lane '#{lane_name}' is defined multiple times!".red if blocks[lane_name]
      if ENV["FASTLANE_PLATFORM_NAME"].nil?
        # No platform specified, assigned configuration by lane name
        blocks[lane_name.to_s] = block
      else
        if ENV["FASTLANE_LANE_NAME"]
          # Platform and lane name specified, assigned lane configuration per different platforms
          blocks[ENV["FASTLANE_PLATFORM_NAME"]] = {lane_name.to_s => block } if lane_name.to_s == ENV["FASTLANE_LANE_NAME"]
        end
      end
    end

    # Override Appfile configuration for a specific platform.
    #
    # platform_name  - Symbol representing a platform name.
    # block - Block to execute to override configuration values.
    #
    # Discussion If received paltform name does not match the platform name available as environment variable, no changes will
    #             be applied.
    def for_platform(platform_name, &block)
      raise "Configuration for platform '#{platform_name}' is defined multiple times!".red if blocks[platform_name]
      blocks[platform_name.to_s] = block
    end

    # Private helpers

    def for_lane_configuration?(block)
      return block[ENV["FASTLANE_LANE_NAME"].to_s] if ENV["FASTLANE_LANE_NAME"]
      false
    end

    def for_platform_configuration?(block)
      return block[ENV["FASTLANE_PLATFORM_NAME"].to_s] if ENV["FASTLANE_PLATFORM_NAME"]
      false
    end
  end
end
