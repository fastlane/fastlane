require 'sigh/version'
require 'sigh/dependency_checker'
require 'sigh/developer_center'
require 'sigh/resign'

require 'fastlane_core'

module Sigh
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  FastlaneCore::UpdateChecker.verify_latest_version('sigh', Sigh::VERSION)
  DependencyChecker.check_dependencies
end
