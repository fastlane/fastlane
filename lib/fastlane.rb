require 'json'
require 'fastlane/version'
require 'fastlane/fast_file'
require 'fastlane/helper'
require 'fastlane/dependency_checker'
require 'fastlane/runner'
require 'fastlane/setup'
require 'fastlane/fastlane_folder'
require 'fastlane/appfile_config'
require 'fastlane/update_checker'

# Third Party code
require 'colored'

module Fastlane
  TMP_FOLDER = "/tmp/fastlane/"

  UpdateChecker.verify_latest_version
end
