require 'coveralls'
Coveralls.wear!

require 'fastlane'
require 'webmock/rspec'

# This module is only used to check the environment is currently a testing env
module SpecHelper
  
end

WebMock.disable_net_connect!(:allow => 'coveralls.io')
WebMock.allow_net_connect!
