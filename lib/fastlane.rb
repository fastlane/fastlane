require 'json'
require 'fastlane/version'
require 'fastlane/fast_file'
require 'fastlane/helper'
require 'fastlane/dependency_checker'
require 'fastlane/runner'
require 'fastlane/setup'
require 'fastlane/fastlane_folder'
require 'fastlane/update_checker'
require 'fastlane/junit_generator'
require 'fastlane/lane_manager'
require 'fastlane/actions/actions_helper'

# Third Party code
require 'colored'

module Fastlane
  TMP_FOLDER = "/tmp/fastlane/"

  UpdateChecker.verify_latest_version

  Fastlane::Actions.load_default_actions
end
