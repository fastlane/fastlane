require 'fastlane_core/helper'
require 'fastlane/boolean'
require_relative 'detect_values'

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
  Boolean = Fastlane::Boolean
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))

  DESCRIPTION = "The easiest way to run tests of your iOS and Mac app"
end
