module Fastlane
  class PluginGenerator
    attr_reader :ui

    def initialize(ui = PluginGeneratorUI.new)
      @ui = ui
    end

    # entry point
    def generate
      collect_info
    end

  private


  end
end
