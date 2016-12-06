require "coveralls"
Coveralls.wear_merged! unless FastlaneCore::Env.enabled?("FASTLANE_SKIP_UPDATE_CHECK")

require 'webmock'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'gym'

WebMock.disable_net_connect!(allow: 'coveralls.io')
