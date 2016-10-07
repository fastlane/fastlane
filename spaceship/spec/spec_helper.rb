require 'simplecov'
require 'coveralls'
Coveralls.wear_merged! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require 'spaceship'
require 'plist'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'client_stubbing'
require 'portal/portal_stubbing'
require 'tunes/tunes_stubbing'
require 'du/du_stubbing'

ENV["DELIVER_USER"] = "spaceship@krausefx.com"
ENV["DELIVER_PASSWORD"] = "so_secret"
ENV.delete("FASTLANE_USER") # just in case the dev env has it

unless ENV["DEBUG"]
  $stdout = File.open("/tmp/spaceship_tests", "w")
end

cache_paths = [
  File.expand_path("/tmp/spaceship_itc_service_key.txt")
]

def try_delete(path)
  FileUtils.rm_f(path) if File.exist? path
end

RSpec.configure do |config|
  config.before(:each) do
    cache_paths.each { |path| try_delete path }
  end

  config.after(:each) do
    cache_paths.each { |path| try_delete path }
  end
end
