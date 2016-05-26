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
    def generate(plugin_name = nil)
      plugin_info = @info_collector.collect_info(plugin_name)

      generate_paths(plugin_info)

      generate_dot_rspec(plugin_info)
      generate_dot_gitignore(plugin_info)
      generate_gemfile(plugin_info)
      generate_gemspec(plugin_info)
      generate_plugin_rb(plugin_info)
      generate_readme(plugin_info)
      generate_version(plugin_info)
      generate_license(plugin_info)
      generate_action(plugin_info)
      generate_helper(plugin_info)
      generate_spec_helper(plugin_info)
      generate_action_spec(plugin_info)
      generate_rakefile(plugin_info)

      @ui.success "\nYour plugin was successfully generated at #{plugin_info.gem_name}/ 🚀"
    end

    def generate_paths(plugin_info)
      FileUtils.mkdir_p(plugin_path(plugin_info, 'lib', plugin_info.require_path))
      FileUtils.mkdir_p(plugin_path(plugin_info, 'lib', plugin_info.actions_path))
      FileUtils.mkdir_p(plugin_path(plugin_info, 'lib', plugin_info.helper_path))
      FileUtils.mkdir_p(plugin_path(plugin_info, 'spec'))
    end

    def generate_dot_rspec(plugin_info)
      write_template(plugin_info, 'dot_rspec.erb', plugin_path(plugin_info, ".rspec"))
    end

    def generate_dot_gitignore(plugin_info)
      write_template(plugin_info, 'dot_gitignore.erb', plugin_path(plugin_info, ".gitignore"))
    end

    def generate_gemfile(plugin_info)
      write_template(plugin_info, 'Gemfile.erb', plugin_path(plugin_info, "Gemfile"))
    end

    def generate_gemspec(plugin_info)
      write_template(plugin_info, 'plugin.gemspec.erb', plugin_path(plugin_info, "#{plugin_info.gem_name}.gemspec"))
    end

    def generate_plugin_rb(plugin_info)
      write_template(plugin_info, 'plugin.rb.erb', plugin_path(plugin_info, 'lib', 'fastlane', 'plugin', "#{plugin_info.plugin_name}.rb"))
    end

    def generate_version(plugin_info)
      write_template(plugin_info, 'version.rb.erb', plugin_path(plugin_info, 'lib', plugin_info.require_path, 'version.rb'))
    end

    def generate_readme(plugin_info)
      write_template(plugin_info, 'README.md.erb', plugin_path(plugin_info, "README.md"))
    end

    def generate_license(plugin_info)
      write_template(plugin_info, 'LICENSE.erb', plugin_path(plugin_info, "LICENSE"))
    end

    def generate_action(plugin_info)
      write_template(plugin_info, 'action.rb.erb', plugin_path(plugin_info, 'lib', plugin_info.actions_path, "#{plugin_info.plugin_name}_action.rb"))
    end

    def generate_helper(plugin_info)
      write_template(plugin_info, 'helper.rb.erb', plugin_path(plugin_info, 'lib', plugin_info.helper_path, "#{plugin_info.plugin_name}_helper.rb"))
    end

    def generate_spec_helper(plugin_info)
      write_template(plugin_info, 'spec_helper.rb.erb', plugin_path(plugin_info, 'spec', 'spec_helper.rb'))
    end

    def generate_action_spec(plugin_info)
      write_template(plugin_info, 'action_spec.rb.erb', plugin_path(plugin_info, 'spec', 'action_spec.rb'))
    end

    def generate_rakefile(plugin_info)
      write_template(plugin_info, 'Rakefile.erb', plugin_path(plugin_info, 'Rakefile'))
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
