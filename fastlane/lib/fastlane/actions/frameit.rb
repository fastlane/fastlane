module Fastlane
  module Actions
    class FrameitAction < Action
      def self.run(config)
        return if Helper.test?

        require 'frameit'

        FastlaneCore::UpdateChecker.start_looking_for_update('frameit') unless Helper.is_test?

        UI.message("Framing screenshots at path #{config[:path]}")

        Dir.chdir(config[:path]) do
          Frameit.config = config
          Frameit::Runner.new.run('.')
        end
      end

      def self.description
        "Adds device frames around the screenshots using frameit"
      end

      def self.details
        [
          "Use [frameit](https://github.com/fastlane/fastlane/tree/master/frameit) to prepare perfect screenshots for the App Store, your website, QA",
          "or emails. You can add background and titles to the framed screenshots as well."
        ].join("\n")
      end

      def self.available_options
        require "frameit"
        require "frameit/options"
        FastlaneCore::CommanderGenerator.new.generate(Frameit::Options.available_options) + [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FRAMEIT_SCREENSHOTS_PATH",
                                       description: "The path to the directory containing the screenshots",
                                        default_value: Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] || FastlaneCore::FastlaneFolder.path)
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.example_code
        [
          'frameit',
          'frameit(silver: true)',
          'frameit(path: "/screenshots")',
          'frameit(rose_gold: true)'
        ]
      end

      def self.category
        :screenshots
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
