require 'json'
require 'gym/manager'
require 'gym/generators/build_command_generator'
require 'gym/generators/package_command_generator'
require 'gym/runner'
require 'gym/error_handler'
require 'gym/options'
require 'gym/detect_values'
require 'gym/xcode'

require 'fastlane_core'
require 'terminal-table'
require 'shellwords'

module Gym
  class << self
    attr_accessor :config

    attr_accessor :project

    attr_accessor :cache

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
      @cache = {}
    end

    def gymfile_name
      "Gymfile"
    end

    def init_libs
      # Import all the fixes
      require 'gym/xcodebuild_fixes/swift_fix'
      require 'gym/xcodebuild_fixes/watchkit_fix'
      require 'gym/xcodebuild_fixes/watchkit2_fix'
      require 'gym/xcodebuild_fixes/generic_archive_fix'
      require 'gym/xcodebuild_fixes/package_application_fix'
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))
  DESCRIPTION = "Building your iOS apps has never been easier"

  Gym.init_libs
end
