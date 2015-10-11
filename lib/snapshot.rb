require 'snapshot/version'
require 'snapshot/runner'
require 'snapshot/reports_generator'
require 'snapshot/detect_values'
require 'snapshot/screenshot_flatten'
require 'snapshot/screenshot_rotate'
require 'snapshot/simulator'
require 'snapshot/dependency_checker'
require 'snapshot/latest_ios_version'
require 'snapshot/test_command_generator'
require 'snapshot/error_handler'
require 'snapshot/collector'
require 'snapshot/options'

require 'fastlane_core'

require 'open3'
require 'pry'

module Snapshot
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config

    attr_accessor :project

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
    end

    def snapfile_name
      "Snapfile"
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore

  Snapshot::DependencyChecker.check_dependencies
end
