require "json"
require "attach/version"
require "attach/manager"
require "attach/project"
require "attach/build_command_generator"
require "attach/package_command_generator"
require "attach/runner"
require 'attach/error_handler'

require "fastlane_core"
require 'terminal-table'

module Attach
  class << self
    attr_accessor :config

    attr_accessor :project

    def config=(value)
      @config = value
      Options.set_additional_default_values
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
end
