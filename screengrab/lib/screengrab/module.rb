require 'fastlane_core/helper'
require_relative 'detect_values'

module Screengrab
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config
    attr_accessor :android_environment

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
    end

    def screengrabfile_name
      "Screengrabfile"
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))
  DESCRIPTION = "Automated localized screenshots of your Android app on every device".freeze
end
