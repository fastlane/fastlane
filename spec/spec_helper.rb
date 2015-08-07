require 'coveralls'
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require 'spaceship'
require 'portal/portal_stubbing'
require 'tunes/tunes_stubbing'
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

cache_paths = [
  "/tmp/spaceship_api_key.txt",
  "/tmp/spaceship_itc_login_url.txt"
]

RSpec.configure do |config|
  config.before(:each) do
    begin
      cache_paths.each { |path| File.delete(path) }
    rescue Errno::ENOENT
    end
  end

  config.after(:each) do
    begin
      cache_paths.each { |path| File.delete(path) }
    rescue Errno::ENOENT
    end
  end
end
