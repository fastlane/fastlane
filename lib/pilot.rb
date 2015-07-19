require 'json'
require 'pilot/version'
require 'pilot/manager'
require 'pilot/tester_manager'
require 'pilot/package_builder'

require 'fastlane_core'
require 'spaceship'

module Pilot
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
end
