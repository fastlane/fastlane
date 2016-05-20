module Fastlane
  class PluginGenerator
    attr_reader :ui

    def initialize(ui = PluginGeneratorUI.new)
      @ui = ui
      @plugin_info_collector = PluginInfoCollector.new(ui)
    end

    # entry point
    def generate
      plugin_info = @plugin_info_collector.collect_info
      generate_plugin(plugin_info)
    end

  private

    def generate_plugin(plugin_info)
      Dir.mkdir(plugin_info.gem_name)

      require 'fileutils'
      File.write('README.md', plugin_info.gem_name)
      FileUtils.touch('LICENSE')
    end

  end
end
