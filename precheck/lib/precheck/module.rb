require 'fastlane_core/helper'
require 'fastlane_core/ui/ui'
require 'fastlane/boolean'

module Precheck
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config

    def precheckfile_name
      "Precheckfile"
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  Boolean = Fastlane::Boolean
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))

  ENV['APP_IDENTIFIER'] ||= ENV["PRECHECK_APP_IDENTIFIER"]

  DESCRIPTION = 'Check your app using a community driven set of App Store review rules to avoid being rejected'
end
