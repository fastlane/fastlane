require 'fastlane_core'

require 'fastlane/version'
require 'fastlane/features'
require 'fastlane/shells'
require 'fastlane/tools'
require 'fastlane/documentation/actions_list'
require 'fastlane/actions/actions_helper' # has to be before fast_file
require 'fastlane/fast_file'
require 'fastlane/runner'
require 'fastlane/setup/setup'
require 'fastlane/lane'
require 'fastlane/junit_generator'
require 'fastlane/lane_manager'
require 'fastlane/lane_manager_base'
require 'fastlane/swift_lane_manager'
require 'fastlane/action'
require 'fastlane/action_collector'
require 'fastlane/supported_platforms'
require 'fastlane/configuration_helper'
require 'fastlane/one_off'
require 'fastlane/server/socket_server_action_command_executor'
require 'fastlane/server/socket_server'
require 'fastlane/command_line_handler'
require 'fastlane/documentation/docs_generator'
require 'fastlane/other_action'
require 'fastlane/plugins/plugins'
require 'fastlane/fastlane_require'

module Fastlane
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))

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
  end
end
