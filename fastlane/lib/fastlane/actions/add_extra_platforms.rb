module Fastlane
  module Actions
    class AddExtraPlatformsAction < Action
      def self.run(params)
        UI.verbose("Before injecting extra platforms: #{Fastlane::SupportedPlatforms.all}")
        Fastlane::SupportedPlatforms.extra = params[:platforms]
        UI.verbose("After injecting extra platforms (#{params[:platforms]})...: #{Fastlane::SupportedPlatforms.all}")
      end

      def self.description
        "Modify the default list of supported platforms"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :platforms,
                                       optional: false,
                                       type: Array,
                                       default_value: "",
                                       description: "The optional extra platforms to support")
        ]
      end

      def self.authors
        ["lacostej"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'add_extra_platforms(
            platforms: [:windows,:neogeo]
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
