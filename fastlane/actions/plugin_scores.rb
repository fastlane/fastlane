module Fastlane
  module Actions
    class PluginScoresAction < Action
      def self.run(params)
        require_relative '../helper/plugin_scores_helper.rb'
        require "erb"

        plugins = fetch_plugins.sort_by { |v| v.data[:overall_score] }.reverse

        result = "<!--\nAuto generated, please only modify https://github.com/fastlane/fastlane/blob/master/fastlane/actions/plugin_scores.rb\n-->\n"
        result += "{!docs/setup-fastlane-header.md!}\n"
        result += "# Available Plugins\n\n\n"
        result += plugins.collect do |current_plugin|
          @plugin = current_plugin
          result = ERB.new(File.read(params[:template_path]), 0, '-').result(binding) # https://web.archive.org/web/20160430190141/www.rrn.dk/rubys-erb-templating-system
        end.join("\n")

        File.write(File.join("docs", params[:output_path]), result)
      end

      def self.fetch_plugins
        page = 1
        plugins = []
        loop do
          url = "https://rubygems.org/api/v1/search.json?query=fastlane-plugin-&page=#{page}"
          puts("RubyGems API Request: #{url}")
          results = JSON.parse(open(url).read)
          break if results.count == 0

          plugins += results.collect do |current|
            next if self.hidden_plugins.include?(current['name'])

            Fastlane::Helper::PluginScoresHelper::FastlanePluginScore.new(current)
          end.compact

          page += 1
        end

        return plugins
      end

      # Metadata
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :output_path),
          FastlaneCore::ConfigItem.new(key: :template_path)
        ]
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.category
        :misc
      end

      # Those are plugins that are now part of fastlane core actions, so we don't want to show them in the directory
      def self.hidden_plugins
        [
          "fastlane-plugin-update_project_codesigning"
        ]
      end
    end
  end
end
