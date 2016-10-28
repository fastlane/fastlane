require 'spec_helper'
require "fastlane/environment_printer"
require "fastlane/cli_tools_distributor"

describe Fastlane do
  describe Fastlane::EnvironmentPrinter do
    before do
      stub_request(:post, %r{https:\/\/fastlane-refresher.herokuapp.com\/.*}).
        with(headers: { 'Host' => 'fastlane-refresher.herokuapp.com:443' }).
        to_return(status: 200, body: '{"version": "0.16.2",  "status": "ok"}', headers: {})
    end

    let(:env) { Fastlane::EnvironmentPrinter.get }

    it "contains the key words" do
      expect(env).to include("fastlane gems")
      expect(env).to include("generated on")
    end

    it "prints out the loaded fastlane plugins" do
      expect(env).to include("Loaded fastlane plugins")
      expect(env).to include("fastlane-plugin-ruby")
    end

    it "prints out the loaded gem dependencies" do
      expect(env).to include("Loaded gems")
      expect(env).to include("addressable")
      expect(env).to include("xcpretty")
    end

    it "contains main information about the stack" do
      expect(env).to include("Bundler?")
      expect(env).to include("Xcode Path")
      expect(env).to include("Xcode Version")
      expect(env).to include("OpenSSL")
    end
  end
end
