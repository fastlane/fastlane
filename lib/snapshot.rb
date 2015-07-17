require 'snapshot/version'
require 'snapshot/snapshot_config'
require 'snapshot/runner'
require 'snapshot/snapshot_file'
require 'snapshot/reports_generator'
require 'snapshot/screenshot_flatten'
require 'snapshot/screenshot_rotate'
require 'snapshot/simulators'
require 'snapshot/dependency_checker'
require 'snapshot/latest_ios_version'

require 'fastlane_core'

require 'open3'

module Snapshot
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config

    def config=(value)
      @config = value
      Options.set_additional_default_values
    end
  end
  
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  Snapshot::DependencyChecker.check_dependencies
end
