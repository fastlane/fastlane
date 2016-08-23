require File.expand_path('../spec_helper', __FILE__)

module Danger
  class Dangerfile
    module DSL
      class GitHubObj
        def pr_body
          ""
        end
      end

      class Plugin
        attr_accessor :current_markdown

        def github # needed for the action
          GitHubObj.new
        end

        def markdown(str)
          @current_markdown ||= ""
          @current_markdown += "#{str}\n"
        end
      end
    end
  end

  describe Danger::DangerDeviceGrid do
    it 'should be a plugin' do
      expect(Danger::DangerDeviceGrid.new(nil)).to be_a Danger::Plugin
    end

    it "works" do
      public_key = "1461233806"
      dg = Danger::DangerDeviceGrid.new(Danger::Dangerfile::DSL::Plugin.new)
      dg.run(languages: ['en', 'de'],
             devices: ['iphone4s'],
             public_key: public_key)

      correct = File.read("spec/fixtures/device_grid_results.html").gsub("[[version]]", Fastlane::VERSION)
      expect(dg.current_markdown).to eq(correct)
    end
  end
end
