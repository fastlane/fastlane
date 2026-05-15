module Fastlane
  module Helper
    class XcodeprojHelper
      DEPENDENCY_MANAGER_DIRS = ['Pods', 'Carthage'].freeze

      def self.find(dir)
        xcodeproj_paths = Dir[File.expand_path(File.join(dir, '**/*.xcodeproj'))]
        xcodeproj_paths.reject { |path| %r{/(#{DEPENDENCY_MANAGER_DIRS.join('|')})/.*.xcodeproj} =~ path }
      end

      def self.get_project!(xcodeproj_path_or_dir)
        require 'xcodeproj'

        if File.extname(xcodeproj_path_or_dir) == ".xcodeproj"
          project_path = xcodeproj_path_or_dir
        else
          project_path = Dir.glob("#{xcodeproj_path_or_dir}/*.xcodeproj").first
        end

        if project_path && File.exist?(project_path)
          return Xcodeproj::Project.open(project_path)
        else
          UI.user_error!("Unable to find Xcode project at #{project_path || xcodeproj_path_or_dir}")
        end
      end

      def self.update_project_build_setting(project, build_setting, value)
        changed = false

        ([project] + project.targets).each do |item|
          item.build_configurations.each do |config|
            next unless config.build_settings.key?(build_setting)

            config.build_settings[build_setting] = value
            changed = true
          end
        end

        changed
      end
    end
  end
end
