module Fastlane
  class PluginSearch
    require 'word_wrap'

    def self.print_plugins(search_query: nil)
      if search_query
        UI.message("Looking for fastlane plugins containing '#{search_query}'...")
      else
        UI.message("Listing all available fastlane plugins")
      end

      plugins = Fastlane::PluginFetcher.fetch_gems(search_query: search_query)

      if plugins.empty?
        UI.user_error!("Couldn't find any available fastlane plugins containing '#{search_query}'")
      end

      rows = plugins.collect do |current|
        [
          current.name.green,
          WordWrap.ww(current.info, 50),
          current.downloads
        ]
      end

      params = {
        rows: FastlaneCore::PrintTable.transform_output(rows),
        title: (search_query ? "fastlane plugins '#{search_query}'" : "Available fastlane plugins").green,
        headings: ["Name", "Description", "Downloads"]
      }

      puts("")
      puts(Terminal::Table.new(params))
      puts("")

      if plugins.count == 1
        print_plugin_details(plugins.last)
      end
    end

    def self.print_plugin_details(plugin)
      UI.message("You can find more information for #{plugin.name} on #{plugin.homepage.green}")
    end
  end
end
