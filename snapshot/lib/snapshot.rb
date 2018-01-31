require_relative 'snapshot/runner'
require_relative 'snapshot/reports_generator'
require_relative 'snapshot/detect_values'
require_relative 'snapshot/screenshot_flatten'
require_relative 'snapshot/screenshot_rotate'
require_relative 'snapshot/dependency_checker'
require_relative 'snapshot/latest_os_version'
require_relative 'snapshot/test_command_generator'
require_relative 'snapshot/test_command_generator_xcode_8'
require_relative 'snapshot/error_handler'
require_relative 'snapshot/collector'
require_relative 'snapshot/options'
require_relative 'snapshot/update'
require_relative 'snapshot/fixes/simulator_zoom_fix'
require_relative 'snapshot/fixes/hardware_keyboard_fix'
require_relative 'snapshot/simulator_launchers/launcher_configuration'
require_relative 'snapshot/simulator_launchers/simulator_launcher'
require_relative 'snapshot/simulator_launchers/simulator_launcher_xcode_8'
require_relative 'snapshot/module'

require 'fastlane_core'

require 'open3'

module Snapshot
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config

    attr_accessor :project

    attr_accessor :cache

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
      @cache = {}
    end

    def snapfile_name
      "Snapfile"
    end

    def kill_simulator
      `killall 'iOS Simulator' &> /dev/null`
      `killall Simulator &> /dev/null`
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))
  DESCRIPTION = "Automate taking localized screenshots of your iOS and tvOS apps on every device"
  CACHE_DIR = File.join(Dir.home, "Library/Caches/tools.fastlane")
  SCREENSHOTS_DIR = File.join(CACHE_DIR, 'screenshots')

  Snapshot::DependencyChecker.check_dependencies

  def self.min_xcode7?
    xcode_version.split(".").first.to_i >= 7
  end
end
