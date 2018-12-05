module Fastlane
  # Generates a sample plugin by traversing a template directory structure
  # and reproducing it in a destination location. At the same time, it runs
  # variable replacements on directory names, file names, and runs ERB
  # templating on file contents whose names end with '.erb'.
  #
  # Directory and file name variable replacements are defined like: %gem_name%
  # The text between the percent signs will be used to invoke an accessor
  # method on the PluginInfo object to get the replacement value.
  class PluginGenerator
    def initialize(ui:             PluginGeneratorUI.new,
                   info_collector: PluginInfoCollector.new(ui),
                   template_root:  File.join(File.dirname(__FILE__), 'template'),
                   dest_root:      FileUtils.pwd)
      @ui = ui
      @info_collector = info_collector
      @template_root = template_root
      @dest_root = dest_root
    end

    # entry point
    def generate(plugin_name = nil)
      plugin_info = @info_collector.collect_info(plugin_name)

      # Traverse all the files and directories in the template root,
      # handling each in turn
      Find.find(@template_root) do |template_path|
        handle_template_path(template_path, plugin_info)
      end

      @ui.success("\nYour plugin was successfully generated at #{plugin_info.gem_name}/ 🚀")
      @ui.success("\nTo get started with using this plugin, run")
      @ui.message("\n    fastlane add_plugin #{plugin_info.plugin_name}\n")
      @ui.success("\nfrom a fastlane-enabled app project directory and provide the following as the path:")
      @ui.message("\n    #{File.expand_path(plugin_info.gem_name)}\n\n")
    end

    def handle_template_path(template_path, plugin_info)
      dest_path = derive_dest_path(template_path, plugin_info)

      if File.directory?(template_path)
        FileUtils.mkdir_p(dest_path)
      else
        copy_file(template_path, dest_path, plugin_info)
      end
    end

    def derive_dest_path(template_path, plugin_info)
      relative_template_path = template_path.gsub(@template_root, '')
      replaced_path = replace_path_variables(relative_template_path, plugin_info)

      File.join(@dest_root, plugin_info.gem_name, replaced_path)
    end

    def copy_file(template_path, dest_path, plugin_info)
      contents = File.read(template_path)

      if dest_path.end_with?('.erb')
        contents = ERB.new(contents).result(plugin_info.get_binding)
        dest_path = dest_path[0...-4] # Remove the .erb suffix
      end

      File.write(dest_path, contents)
    end

    # Path variables can be defined like: %gem_name%
    #
    # The text between the percent signs will be used to invoke an accessor
    # method on the PluginInfo object to be the replacement value.
    def replace_path_variables(template_path, plugin_info)
      path = template_path.dup

      loop do
        replacement_variable_regexp = /%([\w\-]*)%/
        match = replacement_variable_regexp.match(path)

        break unless match

        replacement_value = plugin_info.send(match[1].to_sym)
        path.gsub!(replacement_variable_regexp, replacement_value)
      end

      path
    end
  end
end
