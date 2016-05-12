module Danger
  class Dangerfile
    module DSL
      class Plugin
        attr_accessor :current_markdown

        def pr_body # needed for the action
          ""
        end

        def markdown(str)
          @current_markdown ||= ""
          @current_markdown += "#{str}\n"
        end
      end
    end
  end
end

describe Fastlane do
  describe "DeviceGrid" do
    it "works" do
      require 'fastlane/actions/device_grid/device_grid'
      public_key = "1461233806"
      dg = Danger::Dangerfile::DSL::DeviceGrid.new
      dg.run(languages: ['en', 'de'],
             devices: ['iphone4s'],
             public_key: public_key)

      correct = File.read("spec/fixtures/device_grid_results.html").gsub("[[version]]", Fastlane::VERSION)
      expect(dg.current_markdown).to eq(correct)
    end
  end
end
