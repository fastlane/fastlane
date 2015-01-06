module Fastlane
  module Actions
    module SharedValues
      
    end

    def self.frameit(params)
      
      execute_action("frameit") do
        require 'frameit'

        color = Frameit::Editor::Color::BLACK
        color = Frameit::Editor::Color::SILVER if [:silver, :white].include?params.first

        screenshots_folder = self.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH]
        Dir.chdir(screenshots_folder) do
          Frameit::Editor.new.run('.', color)
        end
      end

    end
  end
end