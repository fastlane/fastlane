require 'coveralls'
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require 'spaceship'
require 'spaceship_stubbing'
require 'plist'
require 'pry'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

ENV["DELIVER_USER"] = "spaceship@krausefx.com"
ENV["DELIVER_PASSWORD"] = "so_secret"

unless ENV["DEBUG"]
  $stdout = File.open("/tmp/spaceship_tests", "w")
end

RSpec.configure do |config|
  config.after(:each) do
    cache_path = "/tmp/spaceship_api_key.txt"
    File.delete(cache_path) rescue nil # to not break the actual spaceship
  end
end
