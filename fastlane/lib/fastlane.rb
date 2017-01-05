require 'fastlane_core'

require 'fastlane/version'
require 'fastlane/features'
require 'fastlane/tools'
require 'fastlane/documentation/actions_list'
require 'fastlane/actions/actions_helper' # has to be before fast_file
require 'fastlane/fast_file'
require 'fastlane/runner'
require 'fastlane/setup/setup'
require 'fastlane/lane'
require 'fastlane/junit_generator'
require 'fastlane/lane_manager'
require 'fastlane/action'
require 'fastlane/action_collector'
require 'fastlane/supported_platforms'
require 'fastlane/configuration_helper'
require 'fastlane/one_off'
require 'fastlane/command_line_handler'
require 'fastlane/documentation/docs_generator'
require 'fastlane/other_action'
require 'fastlane/plugins/plugins'
require 'fastlane/fastlane_require'

module Fastlane
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))
  CONFIG_DIR = File.expand_path("~/.fastlane")

  class << self
    def load_actions
      Fastlane::Actions.load_default_actions
      Fastlane::Actions.load_helpers

      if FastlaneCore::FastlaneFolder.path
        actions_path = File.join(FastlaneCore::FastlaneFolder.path, 'actions')
        Fastlane::Actions.load_external_actions(actions_path) if File.directory?(actions_path)
      end
    end

    def plugin_manager
      @plugin_manager ||= Fastlane::PluginManager.new
    end

    # The location where we can store persistent data
    # This is inside a method, so that it might be a more dynamic
    # value in the future, depending on the system environment
    def config_dir
      CONFIG_DIR
    end

    # This method is called after `require 'fastlane'` was executed
    def init
      # Some of the tools use ~/.fastlane as the location to store
      # persistent data/caches for this machine
      # We need to rescue also, because on some Unix system the user might not
      # have permission to create a directory
      begin
        FileUtils.mkdir_p(config_dir) unless File.directory?(config_dir)
      rescue
        nil
      end
    end
  end

  Fastlane.init
end
