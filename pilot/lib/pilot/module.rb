require_relative '../../../fastlane_core/lib/fastlane_core/require_relative_helper'

require_relative internal('fastlane_core/helper')

module Pilot
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))

  DESCRIPTION = "The best way to manage your TestFlight testers and builds from your terminal"
end
