module Fastlane
  module Actions
    module SharedValues
    end

    class FrameitAction < Action
      def self.run(params)
        return if Helper.test?

        require 'frameit'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('frameit')
          color = Frameit::Editor::Color::BLACK
          color = Frameit::Editor::Color::SILVER if [:silver, :white].include?(params.first)

          screenshots_folder = Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH]
          screenshots_folder ||= FastlaneFolder.path

          Dir.chdir(screenshots_folder) do
            Frameit::Editor.new.run('.', color)
          end
        ensure
          FastlaneCore::UpdateChecker.show_update_status('frameit', Frameit::VERSION)
        end
      end
    end
  end
end
