require "coveralls"
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require "fastlane"
require "webmock/rspec"

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

WebMock.disable_net_connect!(allow: "coveralls.io")
WebMock.allow_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    Fastlane::Actions.clear_lane_context
  end
end
