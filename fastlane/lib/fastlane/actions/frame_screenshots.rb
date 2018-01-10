module Fastlane
  module Actions
    class FrameScreenshotsAction < Action
      def self.run(config)
        return if Helper.test?

        require 'frameit'

        UI.message("Framing screenshots at path #{config[:path]} (via frameit)")

        Dir.chdir(config[:path]) do
          Frameit.config = config
          Frameit::Runner.new.run('.')
        end
      end

      def self.description
        "Adds device frames around all screenshots (via _frameit_)"
      end

      def self.details
        [
          "Uses [frameit](https://docs.fastlane.tools/actions/frameit/) to prepare perfect screenshots for the App Store, your website, QA or emails.",
          "You can add background and titles to the framed screenshots as well."
        ].join("\n")
      end

      def self.available_options
        require "frameit"
        require "frameit/options"
        FastlaneCore::CommanderGenerator.new.generate(Frameit::Options.available_options) + [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FRAMEIT_SCREENSHOTS_PATH",
                                       description: "The path to the directory containing the screenshots",
                                        default_value: Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] || FastlaneCore::FastlaneFolder.path,
                                       default_value_dynamic: true)
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.example_code
        [
          'frame_screenshots',
          'frameit # alias for "frame_screenshots"',
          'frame_screenshots(silver: true)',
          'frame_screenshots(path: "/screenshots")',
          'frame_screenshots(rose_gold: true)'
        ]
      end

      def self.category
        :screenshots
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
