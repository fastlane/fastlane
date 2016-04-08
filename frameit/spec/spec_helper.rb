require 'coveralls'
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require 'frameit'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'webmock'
WebMock.disable_net_connect!(allow: 'coveralls.io')
