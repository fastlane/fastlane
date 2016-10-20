require 'spec_helper'
require "fastlane/environment_printer"
require "fastlane/cli_tools_distributor"

describe Fastlane do
  describe Fastlane::EnvironmentPrinter do
    before do
      stub_request(:post, %r{https:\/\/fastlane-refresher.herokuapp.com\/.*}).
        with(headers: { 'Host' => 'fastlane-refresher.herokuapp.com:443', 'User-Agent' => 'excon/0.53.0' }).
        to_return(status: 200, body: '{"version": "0.16.2",  "status": "ok"}', headers: {})
    end

    it "Prints Env Dump" do
      expect(Fastlane::EnvironmentPrinter.get).to include("fastlane")
      expect(Fastlane::EnvironmentPrinter.get).to include("Loaded fastlane Plugins")
      expect(Fastlane::EnvironmentPrinter.get).to include("fastlane gems")
      expect(Fastlane::EnvironmentPrinter.get).to include("generated at")
    end
  end
end
