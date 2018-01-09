require_relative from_fastlane_core

require_relative from_fastlane/'version'
require_relative from_fastlane/'features'
require_relative from_fastlane/'shells'
require_relative from_fastlane/'tools'
require_relative from_fastlane/'documentation/actions_list'
require_relative from_fastlane/'actions/actions_helper' # has to be before fast_file
require_relative from_fastlane/'fast_file'
require_relative from_fastlane/'runner'
require_relative from_fastlane/'setup/setup'
require_relative from_fastlane/'lane'
require_relative from_fastlane/'junit_generator'
require_relative from_fastlane/'lane_manager'
require_relative from_fastlane/'lane_manager_base'
require_relative from_fastlane/'swift_lane_manager'
require_relative from_fastlane/'action'
require_relative from_fastlane/'action_collector'
require_relative from_fastlane/'supported_platforms'
require_relative from_fastlane/'configuration_helper'
require_relative from_fastlane/'one_off'
require_relative from_fastlane/'server/socket_server_action_command_executor'
require_relative from_fastlane/'server/socket_server'
require_relative from_fastlane/'command_line_handler'
require_relative from_fastlane/'documentation/docs_generator'
require_relative from_fastlane/'other_action'
require_relative from_fastlane/'plugins/plugins'
require_relative from_fastlane/'fastlane_require'

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
