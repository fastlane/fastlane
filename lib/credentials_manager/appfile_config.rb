module CredentialsManager
  # Access the content of the app file (e.g. app identifier and Apple ID)
  class AppfileConfig

    def self.try_fetch_value(key)
      if self.default_path
        begin
          return self.new.data[key]
        rescue => ex
          puts ex.to_s
          return nil
        end
      end
      nil
    end

    def self.default_path
      ["./fastlane/Appfile", "./Appfile"].each do |current|
        return current if File.exist? current
      end
      nil
    end

    def initialize(path = nil)
      path ||= self.class.default_path

      raise "Could not find Appfile at path '#{path}'".red unless File.exist?(path)

      full_path = File.expand_path(path)
      Dir.chdir(File.expand_path('..', path)) do
        # rubocop:disable Lint/Eval
        eval(File.read(full_path))
        # rubocop:enable Lint/Eval
      end
    end

    def data
      @data ||= {}
    end

    # Setters

    def app_identifier(*args, &_block)
      if block_given?
        value = yield
      else
        value = args.shift
      end
      data[:app_identifier] = value if value
    end

    def apple_id(*args, &_block)
      if block_given?
        value = yield
      else
        value = args.shift
      end
      data[:apple_id] = value if value
    end

    def team_id(*args, &_block)
      if block_given?
        value = yield
      else
        value = args.shift
      end
      data[:team_id] = value if value
    end

    def team_name(*args, &_block)
      if block_given?
        value = yield
      else
        value = args.shift
      end
      data[:team_name] = value if value
    end

    # Override Appfile configuration for a specific lane.
    #
    # lane_name  - Symbol representing a lane name. (Can be either :name, 'name' or 'platform name')
    # block - Block to execute to override configuration values.
    #
    # Discussion If received lane name does not match the lane name available as environment variable, no changes will
    #             be applied.
    def for_lane(lane_name, &block)
      if lane_name.to_s.split(" ").count > 1
        # That's the legacy syntax 'platform name'
        puts "You use deprecated syntax '#{lane_name}' in your Appfile.".yellow
        puts "Please follow the Appfile guide: https://github.com/KrauseFx/fastlane/blob/master/docs/Appfile.md".yellow
        platform, lane_name = lane_name.split(" ")

        return unless platform == ENV["FASTLANE_PLATFORM_NAME"]
        # the lane name will be verified below
      end

      if ENV["FASTLANE_LANE_NAME"] == lane_name.to_s
        block.call
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
      if ENV["FASTLANE_PLATFORM_NAME"] == platform_name.to_s
        block.call
      end
    end
  end
end
