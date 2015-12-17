require "json"
require "pilot/version"
require "pilot/manager"
require "pilot/build_manager"
require "pilot/tester_manager"
require "pilot/tester_importer"
require "pilot/tester_exporter"
require "pilot/package_builder"

require "fastlane_core"
require "spaceship"
require "terminal-table"

module Pilot
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
end
