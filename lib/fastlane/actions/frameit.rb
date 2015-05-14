module Fastlane
  module Actions
    class FrameitAction < Action
      def self.run(params)
        return if Helper.test?

        require 'frameit'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('frameit') unless Helper.is_test?
          color = Frameit::Color::BLACK
          color = Frameit::Color::SILVER if (params[:white] or params[:silver])

          screenshots_folder = Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH]
          screenshots_folder ||= FastlaneFolder.path

          Dir.chdir(screenshots_folder) do
            Frameit::Runner.new.run('.', color)
          end
        ensure
          FastlaneCore::UpdateChecker.show_update_status('frameit', Frameit::VERSION)
        end
      end

      def self.description
        "Adds device frames around the screenshots using frameit"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :white,
                                         env_name: "",
                                         description: "Use white device frames",
                                         optional: true,
                                         is_string: false),
          FastlaneCore::ConfigItem.new(key: :silver,
                                         env_name: "",
                                         description: "Use white device frames. Alias for :white",
                                         optional: true,
                                         is_string: false)
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?platform
      end
    end
  end
end
