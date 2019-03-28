module Fastlane
  class PluginSearch
    require 'terminal-table'
    require 'word_wrap'

    def self.print_plugins(search_query: nil)
      if search_query
        UI.message(
          "Looking for fastlane plugins containing '#{search_query}'..."
        )
      else
        UI.message('Listing all available fastlane plugins')
      end

      plugins = Fastlane::PluginFetcher.fetch_gems(search_query: search_query)

      if plugins.empty?
        UI.user_error!(
          "Couldn't find any available fastlane plugins containing '#{search_query}'"
        )
      end

      rows =
        plugins.collect do |current|
          [current.name.green, WordWrap.ww(current.info, 50), current.downloads]
        end

      params = {
        rows: FastlaneCore::PrintTable.transform_output(rows),
        title:
          (
            if search_query
              "fastlane plugins '#{search_query}'"
            else
              'Available fastlane plugins'
            end
          )
            .green,
        headings: %w[Name Description Downloads]
      }

      puts('')
      puts(Terminal::Table.new(params))
      puts('')

      print_plugin_details(plugins.last) if plugins.count == 1
    end

    def self.print_plugin_details(plugin)
      UI.message(
        "You can find more information for #{plugin.name} on #{plugin.homepage
          .green}"
      )
    end
  end
end
