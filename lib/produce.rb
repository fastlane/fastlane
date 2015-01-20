require 'json'
require 'produce/version'
require 'produce/helper'
require 'produce/config'
require 'produce/manager'
require 'produce/dependency_checker'
require 'produce/developer_center'
require 'produce/update_checker'

# Third Party code
require 'colored'

module Produce
  TMP_FOLDER = "/tmp/produce/"

  # Produce::UpdateChecker.verify_latest_version
  DependencyChecker.check_dependencies
end
