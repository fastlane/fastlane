module Fastlane
  class PluginInfoCollector
    def initialize(ui = PluginGeneratorUI.new)
      @ui = ui
    end

    def collect_info
      plugin_name = collect_plugin_name
      author = collect_author

      PluginInfo.new(plugin_name, author)
    end

    #
    # Plugin name
    #

    def collect_plugin_name
      plugin_name = nil
      loop do
        plugin_name = @ui.input("What would you like to be the name of your plugin?")
        unless plugin_name_valid?(plugin_name)
          fixed_name = fix_plugin_name(plugin_name)
          if plugin_name_valid?(fixed_name)
            plugin_name = fixed_name if @ui.confirm("Is '#{fixed_name}' OK?")
          end
        end

        break if plugin_name_valid?(plugin_name)

        @ui.message("Plugin names can only contain lower case letters, numbers, and underscores.")
      end

      plugin_name
    end

    # Consider testing this more directly?
    def plugin_name_valid?(name)
      /^[a-z0-9_]+$/ =~ name && !name.downcase.start_with?('fastlane_')
    end

    def fix_plugin_name(name)
      name.to_s.downcase.gsub(/[\- ]/, '_').gsub(/[^a-z0-9_]/, '').gsub(/^fastlane_/, '')
    end

    #
    # Author
    #

    def collect_author
      author = nil
      loop do
        author = @ui.input("What is the name of the plugin author?")
        break if author_valid?(author)

        @ui.message('An author name is required.')
      end

      author
    end

    def author_valid?(author)
      !author.to_s.strip.empty?
    end

  end
end
