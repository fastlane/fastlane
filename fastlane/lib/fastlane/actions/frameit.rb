module Fastlane
  module Actions
    class FrameitAction < Action
      def self.run(config)
        return if Helper.test?

        require 'frameit'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('frameit') unless Helper.is_test?

          UI.message("Framing screenshots at path #{config[:path]}")

          Dir.chdir(config[:path]) do
            Frameit.config = config
            Frameit::Runner.new.run('.')
          end
        ensure
          FastlaneCore::UpdateChecker.show_update_status('frameit', Frameit::VERSION)
        end
      end

      def self.description
        "Adds device frames around the screenshots using frameit"
      end

      def self.available_options
        require "frameit"
        require "frameit/options"
        FastlaneCore::CommanderGenerator.new.generate(Frameit::Options.available_options) + [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FRAMEIT_SCREENSHOTS_PATH",
                                       description: "The path to the directory containing the screenshots",
                                        default_value: Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] || FastlaneFolder.path)
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
