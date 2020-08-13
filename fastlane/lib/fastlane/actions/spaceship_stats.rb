module Fastlane
  module Actions
    class SpaceshipStatsAction < Action
      def self.run(params)
        require 'fastlane_core/print_table'
        require 'spaceship'

        rows = []
        Spaceship::StatLogger.service_stats.each do |service, count|
          rows << [service.name, service.url, service.auth_type, count]
        end

        puts("")
        puts(Terminal::Table.new(
               title: "Spaceship Stats",
               headings: ["Service", "URL", "Auth Type", "Number of requests"],
               rows: FastlaneCore::PrintTable.transform_output(rows)
        ))
        puts("")
      end

      def self.url_name(url_prefix)
        Spaceship::StatLogger::URL_PREFIXES[url_prefix]
      end

      def self.description
        "Print out Spaceship stats from this session (number of request to each domain)"
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'spaceship_stats'
        ]
      end

      def self.category
        :misc
      end

      def self.author
        "joshdholtz"
      end
    end
  end
end
