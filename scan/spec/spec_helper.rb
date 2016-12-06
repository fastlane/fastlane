require "coveralls"
Coveralls.wear_merged! unless FastlaneCore::Env.enabled?("FASTLANE_SKIP_UPDATE_CHECK")

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'scan'
