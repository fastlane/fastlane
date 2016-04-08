module Fastlane
  module Actions
    class XcovAction < Action
      def self.run(values)
        Actions.verify_gem!('xcov')
        require 'xcov'

        Xcov::Manager.new.work(values)
      end

      def self.description
        "Nice code coverage reports without hassle"
      end

      def self.details
        "More information: https://github.com/nakiostudio/xcov"
      end

      def self.author
        "nakiostudio"
      end

      def self.available_options
        # We call Gem::Specification.find_by_name in many more places than this, but for right now
        # this is the only place we're having trouble. If there are other reports about RubyGems
        # 2.6.2 causing problems, we may need to move this code and require it someplace better,
        # like fastlane_core
        require 'fastlane/core_ext/bundler_monkey_patch'

        begin
          Gem::Specification.find_by_name('xcov')
        rescue Gem::LoadError
          # Catched missing gem exception and returned empty array
          # to avoid unused_options_spec failure
          return []
        end

        require 'xcov'
        Xcov::Options.available_options
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
