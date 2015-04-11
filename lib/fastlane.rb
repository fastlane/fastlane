require 'fastlane/core_ext/string' # this has to be above most of the other requires
require 'fastlane/version'
require 'fastlane/fast_file'
require 'fastlane/dependency_checker'
require 'fastlane/runner'
require 'fastlane/setup'
require 'fastlane/fastlane_folder'
require 'fastlane/junit_generator'
require 'fastlane/lane_manager'
require 'fastlane/action'
require 'fastlane/actions/actions_helper'

require 'fastlane_core'

# Third Party code
require 'colored'

module Fastlane
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  Fastlane::Actions.load_default_actions

  if Fastlane::FastlaneFolder.path
    actions_path = File.join(Fastlane::FastlaneFolder.path, 'actions')
    Fastlane::Actions.load_external_actions(actions_path) if File.directory?(actions_path)
  end
end
