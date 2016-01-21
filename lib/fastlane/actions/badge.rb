module Fastlane
  module Actions
    class BadgeAction < Action
      def self.run(params)
        require 'badge'
        Badge::Runner.new.run('.', params[:dark], params[:custom], params[:no_badge], params[:shield])
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Automatically add a badge to your iOS app icon"
      end

      def self.details
        [
          "This action will add a light/dark beta badge onto your app icon.",
          "You can also provide your custom badge/overlay or add an shield for more customization more info:",
          "https://github.com/HazAT/badge"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :dark,
                                       env_name: "FL_BADGE_DARK",
                                       description: "adds a dark flavored badge ontop of your icon",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "dark is only a flag and should always be true".red unless value == true
                                       end),
          FastlaneCore::ConfigItem.new(key: :custom,
                                       env_name: "FL_BADGE_CUSTOM",
                                       description: "add your custom overlay/badge image",
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "custom should be a valid file path".red unless value and File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_badge,
                                       env_name: "FL_BADGE_NO_BADGE",
                                       description: "hides the beta badge",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "no_badge is only a flag and should always be true".red unless value == true
                                       end),
          FastlaneCore::ConfigItem.new(key: :shield,
                                       env_name: "FL_BADGE_SHIELD",
                                       description: "add a shield to your app icon from shield.io",
                                       optional: true,
                                       is_string: true)
        ]
      end

      def self.authors
        ["DanielGri"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
