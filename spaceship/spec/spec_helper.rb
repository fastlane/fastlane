require 'spaceship'
require 'plist'
require 'pry'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'simplecov'
require 'coveralls'
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require 'client_stubbing'
require 'portal/portal_stubbing'
require 'tunes/tunes_stubbing'
require 'du/du_stubbing'

SimpleCov.at_exit do
  puts "Coverage done"
  SimpleCov.result.format!
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start

ENV["DELIVER_USER"] = "spaceship@krausefx.com"
ENV["DELIVER_PASSWORD"] = "so_secret"
ENV.delete("FASTLANE_USER") # just in case the dev env has it

unless ENV["DEBUG"]
  $stdout = File.open("/tmp/spaceship_tests", "w")
end

cache_paths = [
  File.expand_path("~/Library/Caches/spaceship_api_key.txt"),
  "/tmp/spaceship_itc_login_url.txt"
]

def try_delete(path)
  FileUtils.rm_f path if File.exist? path
end

RSpec.configure do |config|
  config.before(:each) do
    cache_paths.each { |path| try_delete path }
  end

  config.after(:each) do
    cache_paths.each { |path| try_delete path }
  end
end
