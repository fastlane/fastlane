module Fastlane
  module Actions
    def self.frameit(params)
      
      execute_action("frameit") do
        need_gem!'frameit'

        require 'frameit'
        require 'frameit/dependency_checker'

        color = Frameit::Editor::Color::BLACK
        color = Frameit::Editor::Color::SILVER if [:silver, :white].include?params.first

        screenshots_folder = File.join(Fastlane::FastlaneFolder::path, self.snapshot_screenshots_folder)
        Dir.chdir(screenshots_folder) do
          Frameit::Editor.new.run('.', color)
        end
      end

    end
  end
end