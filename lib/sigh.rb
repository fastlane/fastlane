require 'json'
require 'sigh/version'
require 'sigh/helper'
require 'sigh/dependency_checker'
require 'sigh/developer_center'
require 'fastlane/update_checker'

# Third Party code
require 'colored'

module Sigh
  TMP_FOLDER = "/tmp/sigh/"

  Fastlane::UpdateChecker.verify_latest_version
  DependencyChecker.check_dependencies
end
