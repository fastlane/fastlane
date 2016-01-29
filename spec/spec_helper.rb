require 'coveralls'
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

unless ENV["DEBUG"]
  $stdout = File.open("/tmp/spaceship_tests", "w")
end

require 'fastlane'
require 'fastlane_core'
require 'webmock/rspec'

UI = FastlaneCore::UI

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

  config.after(:each) do
    md_path = "spec/fixtures/fastfiles/README.md"
    File.delete(md_path) if File.exist?(md_path)
  end
end
