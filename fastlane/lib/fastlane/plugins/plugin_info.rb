module Fastlane
  class PluginInfo
    attr_reader :plugin_name
    attr_reader :author
    attr_reader :gem_name

    def initialize(plugin_name, author)
      @plugin_name = plugin_name
      @author = author
    end

    def gem_name
      "fastlane_#{plugin_name}"
    end

    # Used to exposed a local binding for use in ERB templating
    def get_binding
      binding
    end

    def ==(other)
      @plugin_name == other.plugin_name &&
      @author == other.author
    end
  end
end
