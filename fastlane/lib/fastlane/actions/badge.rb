module Fastlane
  module Actions
    class BadgeAction < Action
      def self.run(params)
        UI.important('The badge action has been deprecated,')
        UI.important('please checkout the badge plugin here:')
        UI.important('https://github.com/HazAT/fastlane-plugin-badge')
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
        begin
          Badge::Runner.new.run(params[:path], options)
        rescue => e
          # We want to catch this error and raise our own so that we are not counting this as a crash in our metrics
          UI.verbose(e.backtrace.join("\n"))
          UI.user_error!("Something went wrong while running badge: #{e}")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Automatically add a badge to your app icon"
      end

      def self.details
        [
          "Please use the [badge plugin](https://github.com/HazAT/fastlane-plugin-badge) instead.",
          "This action will add a light/dark badge onto your app icon.",
          "You can also provide your custom badge/overlay or add a shield for more customization.",
          "More info: [https://github.com/HazAT/badge](https://github.com/HazAT/badge)",
          "**Note**: If you want to reset the badge back to default, you can use `sh 'git checkout -- <path>/Assets.xcassets/'`."
        ].join("\n")
      end

      def self.example_code
        [
          'badge(dark: true)',
          'badge(alpha: true)',
          'badge(custom: "/Users/xxx/Desktop/badge.png")',
          'badge(shield: "Version-0.0.3-blue", no_badge: true)'
        ]
      end

      def self.category
        :deprecated
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dark,
                                       env_name: "FL_BADGE_DARK",
                                       description: "Adds a dark flavored badge on top of your icon",
                                       optional: true,
                                       type: Boolean,
                                       verify_block: proc do |value|
                                         UI.user_error!("dark is only a flag and should always be true") unless value == true
                                       end),
          FastlaneCore::ConfigItem.new(key: :custom,
                                       env_name: "FL_BADGE_CUSTOM",
                                       description: "Add your custom overlay/badge image",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("custom should be a valid file path") unless value && File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_badge,
                                       env_name: "FL_BADGE_NO_BADGE",
                                       description: "Hides the beta badge",
                                       optional: true,
                                       type: Boolean,
                                       verify_block: proc do |value|
                                         UI.user_error!("no_badge is only a flag and should always be true") unless value == true
                                       end),
          FastlaneCore::ConfigItem.new(key: :shield,
                                       env_name: "FL_BADGE_SHIELD",
                                       description: "Add a shield to your app icon from shields.io",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :alpha,
                                       env_name: "FL_BADGE_ALPHA",
                                       description: "Adds and alpha badge instead of the default beta one",
                                       optional: true,
                                       type: Boolean,
                                       verify_block: proc do |value|
                                         UI.user_error!("alpha is only a flag and should always be true") unless value == true
                                       end),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_BADGE_PATH",
                                       description: "Sets the root path to look for AppIcons",
                                       optional: true,
                                       default_value: '.',
                                       verify_block: proc do |value|
                                         UI.user_error!("path needs to be a valid directory") if Dir[value].empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :shield_io_timeout,
                                       env_name: "FL_BADGE_SHIELD_IO_TIMEOUT",
                                       description: "Set custom duration for the timeout of the shields.io request in seconds",
                                       optional: true,
                                       type: Integer, # allow integers, strings both
                                       verify_block: proc do |value|
                                         UI.user_error!("shield_io_timeout needs to be an integer > 0") if value.to_i < 1
                                       end),
          FastlaneCore::ConfigItem.new(key: :glob,
                                       env_name: "FL_BADGE_GLOB",
                                       description: "Glob pattern for finding image files",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :alpha_channel,
                                       env_name: "FL_BADGE_ALPHA_CHANNEL",
                                       description: "Keeps/adds an alpha channel to the icon (useful for android icons)",
                                       optional: true,
                                       type: Boolean,
                                       verify_block: proc do |value|
                                         UI.user_error!("alpha_channel is only a flag and should always be true") unless value == true
                                       end),
          FastlaneCore::ConfigItem.new(key: :shield_gravity,
                                       env_name: "FL_BADGE_SHIELD_GRAVITY",
                                       description: "Position of shield on icon. Default: North - Choices include: NorthWest, North, NorthEast, West, Center, East, SouthWest, South, SouthEast",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :shield_no_resize,
                                       env_name: "FL_BADGE_SHIELD_NO_RESIZE",
                                       description: "Shield image will no longer be resized to aspect fill the full icon. Instead it will only be shrunk to not exceed the icon graphic",
                                       optional: true,
                                       type: Boolean,
                                       verify_block: proc do |value|
                                         UI.user_error!("shield_no_resize is only a flag and should always be true") unless value == true
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
