require 'json'
require 'scan/manager'
require 'scan/options'
require 'scan/runner'
require 'scan/detect_values'
require 'scan/report_collector'
require 'scan/test_command_generator'
require 'scan/test_result_parser'
require 'scan/error_handler'
require 'scan/slack_poster'

require 'fastlane_core'

module Scan
  class << self
    attr_accessor :config

    attr_accessor :project

    attr_accessor :cache

    attr_accessor :devices

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
      @cache = {}
    end

    def scanfile_name
      "Scanfile"
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))

  DESCRIPTION = "The easiest way to run tests of your iOS and Mac app"
end
