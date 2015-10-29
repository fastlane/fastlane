require 'fastlane/core_ext/string' # this has to be above most of the other requires
require 'fastlane/version'
require 'fastlane/actions/actions_helper' # has to be before fast_file
require 'fastlane/fast_file'
require 'fastlane/dependency_checker'
require 'fastlane/runner'
require 'fastlane/setup/setup'
require 'fastlane/lane'
require 'fastlane/fastlane_folder'
require 'fastlane/junit_generator'
require 'fastlane/lane_manager'
require 'fastlane/action'
require 'fastlane/action_collector'
require 'fastlane/supported_platforms'
require 'fastlane/configuration_helper'
require 'fastlane/command_line_handler'

require 'fastlane_core'

module Fastlane
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  Fastlane::Actions.load_default_actions
  Fastlane::Actions.load_helpers

  if Fastlane::FastlaneFolder.path
    actions_path = File.join(Fastlane::FastlaneFolder.path, 'actions')
    Fastlane::Actions.load_external_actions(actions_path) if File.directory?(actions_path)
  end
end
