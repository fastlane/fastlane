require 'fileutils'
require 'erb'

module Fastlane
  class PluginGenerator
    def initialize(ui             = PluginGeneratorUI.new,
                   info_collector = PluginInfoCollector.new(ui))
      @ui = ui
      @info_collector = info_collector
    end

    # entry point
    def generate
      plugin_info = @info_collector.collect_info

      generate_paths(plugin_info)

      generate_gemspec(plugin_info)
      generate_readme(plugin_info)
      generate_version(plugin_info)
      generate_license(plugin_info)
    end

    def generate_paths(plugin_info)
      Dir.mkdir(plugin_info.gem_name)
      FileUtils.mkdir_p(File.join('lib', plugin_info.gem_name))
    end

    def generate_gemspec(plugin_info)
      write_template(plugin_info, 'plugin.gemspec.erb', "#{plugin_info.gem_name}.gemspec")
    end

    def generate_version(plugin_info)
      write_template(plugin_info, 'version.rb.erb', File.join('lib', plugin_info.gem_name, 'version.rb'))
    end

    def generate_readme(plugin_info)
      write_template(plugin_info, 'README.md.erb', 'README.md')
    end

    def generate_license(plugin_info)
      FileUtils.touch('LICENSE')
    end

    def write_template(plugin_info, template_name, dest_path)
      template = File.join(File.dirname(__FILE__), 'templates', template_name)
      erb = ERB.new(File.read(template))
      result = erb.result(plugin_info.get_binding)
      File.write(dest_path, result)
    end
  end
end
