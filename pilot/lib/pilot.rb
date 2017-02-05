# fastlane_core must be required before 'pilot/features' which depends on it for FastlaneCore::Feature
require "fastlane_core"

require "json"
require 'pilot/features'
require "pilot/options"
require "pilot/manager"
require "pilot/build_manager"
require "pilot/tester_manager"
require "pilot/tester_importer"
require "pilot/tester_exporter"

require "spaceship"
require "terminal-table"

module Pilot
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))

  DESCRIPTION = "The best way to manage your TestFlight testers and builds from your terminal"
end
