require 'coveralls'
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require 'match'
require 'webmock/rspec'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

WebMock.disable_net_connect!(allow: 'coveralls.io')

RSpec::Matchers.define :a_configuration_matching do |expected|
  match do |actual|
    actual._values == expected._values
  end
end
