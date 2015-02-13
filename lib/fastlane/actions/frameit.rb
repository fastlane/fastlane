module Fastlane
  module Actions
    module SharedValues
      
    end

    class FrameitAction
      def self.run(params)
        return if Helper.is_test?
        
        require 'frameit'

        color = Frameit::Editor::Color::BLACK
        color = Frameit::Editor::Color::SILVER if [:silver, :white].include?params.first

        screenshots_folder = Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH]
        screenshots_folder ||= FastlaneFolder.path

        Dir.chdir(screenshots_folder) do
          Frameit::Editor.new.run('.', color)
        end
      end
    end
  end
end
