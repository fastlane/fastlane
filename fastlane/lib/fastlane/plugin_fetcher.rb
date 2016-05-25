module Fastlane
  # Use the RubyGems API to get all fastlane plugins
  class PluginFetcher
    require 'fastlane_core'
    require 'fastlane/plugin_manager'

    def run
      require 'json'
      require 'open-uri'
      url = "https://rubygems.org/api/v1/search.json?query=#{PluginManager.plugin_prefix}"
      results = JSON.parse(open(url).read)
      @plugins = results.collect do |current|
        FastlanePlugin.new(current)
      end

      lib_path = FastlaneCore::Helper.gem_path('fastlane')
      template_path = File.join(lib_path, "lib/assets/Plugins.md.erb")
      md = ERB.new(File.read(template_path), nil, '<>').result(binding) # http://www.rrn.dk/rubys-erb-templating-system

      puts md
      output_path = "docs/AvailablePlugins.md"
      File.write(output_path, md)
      FastlaneCore::UI.success("Successfully written plugin file to '#{output_path}'")
    end
  end

  class FastlanePlugin
    attr_accessor :full_name
    attr_accessor :name
    attr_accessor :downloads
    attr_accessor :info
    attr_accessor :homepage

    def initialize(hash)
      self.full_name = hash["name"]
      self.name = self.full_name.gsub(PluginManager.plugin_prefix, '')
      self.downloads = hash["downloads"]
      self.info = hash["info"]
      self.homepage = hash["homepage_uri"]
    end

    def linked_title
      return "`#{name}`" if homepage.to_s.length == 0
      return "[#{name}](#{homepage})"
    end
  end
end
