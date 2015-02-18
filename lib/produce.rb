require 'json'
require 'produce/version'
require 'produce/config'
require 'produce/manager'
require 'produce/dependency_checker'
require 'produce/developer_center'
require 'produce/itunes_connect'
require 'produce/available_default_languages'

module Produce
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  FastlaneCore::UpdateChecker.verify_latest_version('produce', Produce::VERSION)
  DependencyChecker.check_dependencies
end
