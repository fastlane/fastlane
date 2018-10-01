require_relative '../../../fastlane_core/lib/fastlane_core/require_relative_helper'

require_relative internal('fastlane_core/ui/ui')
require_relative internal('fastlane_core/helper')
require_relative internal('fastlane_core/fastlane_folder')

module Fastlane
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))

  class << self
    def load_actions
      require_relative 'actions/actions_helper'
      Fastlane::Actions.load_default_actions
      Fastlane::Actions.load_helpers

      if FastlaneCore::FastlaneFolder.path
        actions_path = File.join(FastlaneCore::FastlaneFolder.path, 'actions')
        Fastlane::Actions.load_external_actions(actions_path) if File.directory?(actions_path)
      end
    end

    def plugin_manager
      require_relative 'plugins/plugin_manager'
      @plugin_manager ||= Fastlane::PluginManager.new
    end
  end
end
