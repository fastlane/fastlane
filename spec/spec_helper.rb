require 'coveralls'
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

unless ENV["DEBUG"]
  $stdout = File.open("/tmp/spaceship_tests", "w")
end

require 'fastlane'
require 'webmock/rspec'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

WebMock.disable_net_connect!(allow: 'coveralls.io')

RSpec.configure do |config|
  config.before(:each) do
    Fastlane::Actions.clear_lane_context

    ENV.delete 'DELIVER_SCREENSHOTS_PATH'
    ENV.delete 'DELIVER_SKIP_BINARY'
    ENV.delete 'DELIVER_VERSION'
  end
end
