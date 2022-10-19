module Fastlane
  module Helper
    class XcodeprojHelper
      DEPENDENCY_MANAGER_DIRS = ['Pods', 'Carthage'].freeze

      def self.find(dir)
        xcodeproj_paths = Dir[File.expand_path(File.join(dir, '**/*.xcodeproj'))]
        xcodeproj_paths.grep_v(%r{/(#{DEPENDENCY_MANAGER_DIRS.join('|')})/.*.xcodeproj})
      end
    end
  end
end
