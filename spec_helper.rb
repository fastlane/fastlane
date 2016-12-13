puts "Root spec helper"

require "coveralls"
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require "webmock/rspec"
WebMock.disable_net_connect!(allow: 'coveralls.io')

require "fastlane"

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

Fastlane::TOOLS.each do |tool|
  path = File.join(tool.to_s, "spec", "spec_helper.rb")
  next unless tool == :sigh || tool == :deliver || tool == :fastlane
  require_relative path if File.exist?(path)
  require tool.to_s
end

RSpec.configure do |c|
  c.example_status_persistence_file_path = "examples.txt"
end

