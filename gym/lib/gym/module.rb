require 'fastlane_core/helper'
require 'fastlane/boolean'
require_relative 'detect_values'

module Gym
  class << self
    attr_accessor :config

    attr_accessor :project

    attr_accessor :cache

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
      @cache = {}
    end

    def gymfile_name
      "Gymfile"
    end

    def init_libs
      # Import all the fixes
      require 'gym/xcodebuild_fixes/generic_archive_fix'
    end

    def building_mac_catalyst_for_ios?
      Gym.project.supports_mac_catalyst? && Gym.config[:catalyst_platform] == "ios"
    end

    def building_mac_catalyst_for_mac?
      Gym.project.supports_mac_catalyst? && Gym.config[:catalyst_platform] == "macos"
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  Boolean = Fastlane::Boolean
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))
  DESCRIPTION = "Building your iOS apps has never been easier"

  Gym.init_libs
end
