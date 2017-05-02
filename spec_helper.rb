require "coveralls"
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require "webmock/rspec"
WebMock.disable_net_connect!(allow: 'coveralls.io')

require "fastlane"
UI = FastlaneCore::UI

unless ENV["DEBUG"]
  $stdout.puts "Changing stdout to /tmp/fastlane_tests, set `DEBUG` environment variable to print to stdout (e.g. when using `pry`)"
  $stdout = File.open("/tmp/fastlane_tests", "w")
end

xcode_path = FastlaneCore::Helper.xcode_path
unless xcode_path.include?("Contents/Developer")
  UI.error("Seems like you didn't set the developer tools path correctly")
  UI.error("Detected path '#{xcode_path}'") if xcode_path.to_s.length > 0
  UI.error("Please run the following on your machine")
  UI.command("sudo xcode-select -s /Applications/Xcode.app")
  UI.error("Adapt the path if you have Xcode installed/named somewhere else")
  exit(1)
end

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
    # We don't want to call the RubyGems API at any point
    # This was a request that was added with Ruby 2.4.0
    allow(Fastlane::FastlaneRequire).to receive(:install_gem_if_needed).and_return(nil)

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

module FastlaneSpec
  module Env
    # a wrapper to temporarily modify the values of ARGV to
    # avoid errors like: "warning: already initialized constant ARGV"
    # if no block is given, modifies ARGV for good
    # rubocop:disable Style/MethodName
    def self.with_ARGV(argv)
      copy = ARGV.dup
      ARGV.clear
      ARGV.concat(argv)
      if block_given?
        begin
          yield
        ensure
          ARGV.clear
          ARGV.concat(copy)
        end
      end
    end
    # rubocop:enable Style/MethodName
  end
end
