module Fastlane
  # Use the RubyGems API to get all fastlane plugins
  class PluginFetcher
    require 'fastlane_core'
    require 'fastlane/plugins/plugin_manager'

    # Returns an array of FastlanePlugin objects
    def self.fetch_gems(search_query: nil)
      require 'json'
      require 'open-uri'

      page = 1
      plugins = []
      loop do
        url = "https://rubygems.org/api/v1/search.json?query=#{PluginManager.plugin_prefix}&page=#{page}"
        FastlaneCore::UI.verbose("RubyGems API Request: #{url}")
        results = JSON.parse(URI.open(url).read)
        break if results.count == 0

        plugins += results.collect do |current|
          FastlanePlugin.new(current)
        end
        page += 1
      end

      return plugins if search_query.to_s.length == 0
      plugins.keep_if do |current|
        current.full_name.include?(search_query) or current.info.include?(search_query)
      end

      return plugins
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
