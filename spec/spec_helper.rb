require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'fastlane'
require 'webmock/rspec'

# This module is only used to check the environment is currently a testing env
module SpecHelper
  
end

# WebMock.disable_net_connect!(:allow => 'codeclimate.com')
WebMock.allow_net_connect!
