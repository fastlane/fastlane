require 'json'
require 'snapshot/version'
require 'snapshot/helper'
require 'snapshot/snapshot_config'
require 'snapshot/runner'
require 'snapshot/builder'
require 'snapshot/snapshot_file'
require 'snapshot/reports_generator'
require 'snapshot/screenshot_flatten'
require 'snapshot/simulators'
require 'snapshot/update_checker'
require 'snapshot/dependency_checker'

# Third Party code
require 'colored'

module Snapshot
  Snapshot::UpdateChecker.verify_latest_version
  Snapshot::DependencyChecker.check_dependencies
end
