require 'coveralls'
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require 'fastlane_core'

require 'webmock/rspec'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end
