require 'json'
require 'gym/version'
require 'gym/manager'
require 'gym/project'
require 'gym/build_command_generator'
require 'gym/package_command_generator'
require 'gym/swift_library_fix_service'
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
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
end
