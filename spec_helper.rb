require "coveralls"
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require "webmock/rspec"
WebMock.disable_net_connect!(allow: 'coveralls.io')

require "fastlane"
UI = FastlaneCore::UI

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

(Fastlane::TOOLS + [:spaceship, :fastlane_core]).each do |tool|
  path = File.join(tool.to_s, "spec", "spec_helper.rb")
  require_relative path if File.exist?(path)
  require tool.to_s
end

my_main = self
RSpec.configure do |config|
  config.before(:each) do |current_test|
    tool_name = current_test.id.match(%r{\.\/(\w+)\/})[1]
    method_name = "before_each_#{tool_name}".to_sym
    begin
      my_main.send(method_name)
    rescue NoMethodError
      # no method implemented
    end
  end

  config.after(:each) do |current_test|
    tool_name = current_test.id.match(%r{\.\/(\w+)\/})[1]
    method_name = "after_each_#{tool_name}".to_sym
    begin
      my_main.send(method_name)
    rescue NoMethodError
      # no method implemented
    end
  end

  config.example_status_persistence_file_path = "/tmp/rspec_failed_tests.txt"
end
