require 'json'
require 'gym/version'
require 'gym/manager'
require 'gym/project'
require 'gym/build_command_generator'
require 'gym/package_command_generator'
require 'gym/runner'
require 'gym/error_handler'
require 'gym/options'
require 'gym/detect_values'

require 'fastlane_core'
require 'terminal-table'

module Gym
  class << self
    attr_accessor :config

    attr_accessor :project

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
    end

    def gymfile_name
      "Gymfile"
    end

    def xcode_path
      @path ||= `xcode-select --print-path`.strip
    end

    def xcode_version
      @version ||= parse_version
    end

    def pre_7?
      v = xcode_version
      is_pre = v.split('.')[0].to_i < 7
      is_pre
    end

    def init_libs
      return unless pre_7?
      # Import all the fixes
      require 'gym/xcodebuild_fixes/swift_fix'
      require 'gym/xcodebuild_fixes/watchkit_fix'
      require 'gym/xcodebuild_fixes/package_application_fix'
    end

    private

    def parse_version
      output = `DEVELOPER_DIR='' "#{xcode_path}/usr/bin/xcodebuild" -version`
      return '0.0' if output.nil?
      output.split("\n").first.split(' ')[1]
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  Gym.init_libs
end
