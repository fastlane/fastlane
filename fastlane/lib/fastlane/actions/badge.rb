module Fastlane
  module Actions
    class BadgeAction < Action
      def self.run(params)
        Actions.verify_gem!('badge')
        require 'badge'
        options = {
          dark: params[:dark],
          custom: params[:custom],
          no_badge: params[:no_badge],
          shield: params[:shield],
          alpha: params[:alpha],
          shield_io_timeout: params[:shield_io_timeout],
          glob: params[:glob],
          alpha_channel: params[:alpha_channel],
          shield_gravity: params[:shield_gravity],
          shield_no_resize: params[:shield_no_resize]
        }
        Badge::Runner.new.run(params[:path], options)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Automatically add a badge to your iOS app icon"
      end

      def self.details
        [
          "This action will add a light/dark badge onto your app icon.",
          "You can also provide your custom badge/overlay or add an shield for more customization more info:",
          "https://github.com/HazAT/badge"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dark,
                                       env_name: "FL_BADGE_DARK",
                                       description: "Adds a dark flavored badge ontop of your icon",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "dark is only a flag and should always be true".red unless value == true
                                       end),
          FastlaneCore::ConfigItem.new(key: :custom,
                                       env_name: "FL_BADGE_CUSTOM",
                                       description: "Add your custom overlay/badge image",
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "custom should be a valid file path".red unless value and File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_badge,
                                       env_name: "FL_BADGE_NO_BADGE",
                                       description: "Hides the beta badge",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "no_badge is only a flag and should always be true".red unless value == true
                                       end),
          FastlaneCore::ConfigItem.new(key: :shield,
                                       env_name: "FL_BADGE_SHIELD",
                                       description: "Add a shield to your app icon from shield.io",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :alpha,
                                       env_name: "FL_BADGE_ALPHA",
                                       description: "Adds and alpha badge instead of the default beta one",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "alpha is only a flag and should always be true".red unless value == true
                                       end),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_BADGE_PATH",
                                       description: "Sets the root path to look for AppIcons",
                                       optional: true,
                                       is_string: true,
                                       default_value: '.',
                                       verify_block: proc do |value|
                                         raise "path needs to be a valid directory".red if Dir[value].empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :shield_io_timeout,
                                       env_name: "FL_BADGE_SHIELD_IO_TIMEOUT",
                                       description: "Set custom duration for the timeout of the shield.io request in seconds",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "shield_io_timeout needs to be an integer > 0".red if value.to_i < 1
                                       end),
          FastlaneCore::ConfigItem.new(key: :glob,
                                       env_name: "FL_BADGE_GLOB",
                                       description: "Glob pattern for finding image files",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :alpha_channel,
                                       env_name: "FL_BADGE_ALPHA_CHANNEL",
                                       description: "Keeps/adds an alpha channel to the icon (useful for android icons)",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "alpha_channel is only a flag and should always be true".red unless value == true
                                       end),
          FastlaneCore::ConfigItem.new(key: :shield_gravity,
                                       env_name: "FL_BADGE_SHIELD_GRAVITY",
                                       description: "Position of shield on icon. Default: North - Choices include: NorthWest, North, NorthEast, West, Center, East, SouthWest, South, SouthEast",
                                       optional: true,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :shield_no_resize,
                                       env_name: "FL_BADGE_SHIELD_NO_RESIZE",
                                       description: "Shield image will no longer be resized to aspect fill the full icon. Instead it will only be shrinked to not exceed the icon graphic",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "shield_no_resize is only a flag and should always be true".red unless value == true
                                       end)
        ]
      end

      def self.authors
        ["DanielGri"]
      end

      def self.is_supported?(platform)
        [:ios, :mac, :android].include?(platform)
      end
    end
  end
end
