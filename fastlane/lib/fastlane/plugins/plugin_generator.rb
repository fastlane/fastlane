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
      FileUtils.mkdir_p(plugin_path(plugin_info, 'lib', plugin_info.require_path))
    end

    def generate_gemspec(plugin_info)
      write_template(plugin_info, 'plugin.gemspec.erb', plugin_path(plugin_info, "#{plugin_info.gem_name}.gemspec"))
    end

    def generate_version(plugin_info)
      write_template(plugin_info, 'version.rb.erb', plugin_path(plugin_info, 'lib', plugin_info.require_path, 'version.rb'))
    end

    def generate_readme(plugin_info)
      write_template(plugin_info, 'README.md.erb', plugin_path(plugin_info, "README.md"))
    end

    def generate_license(plugin_info)
      FileUtils.touch(plugin_path(plugin_info, 'LICENSE'))
    end

    def write_template(plugin_info, template_name, dest_path)
      template = File.join(File.dirname(__FILE__), 'templates', template_name)
      erb = ERB.new(File.read(template))
      result = erb.result(plugin_info.get_binding)
      File.write(dest_path, result)
    end

    def plugin_path(plugin_info, *path)
      File.join(plugin_info.gem_name, *path)
    end
  end
end
