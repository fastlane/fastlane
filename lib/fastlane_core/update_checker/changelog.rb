require 'excon'

module FastlaneCore
  class Changelog
    class << self
      def show_changes(gem_name, current_version)
        self.releases(gem_name).each do |release|
          next unless Gem::Version.new(release['tag_name']) > Gem::Version.new(current_version)
          puts ""
          puts release['name'].green
          puts release['body']
        end
        puts "\nUpdate using 'sudo gem update #{gem_name.downcase}'".green
      end

      def releases(gem_name)
        url = "https://api.github.com/repos/fastlane/#{gem_name}/releases"
        JSON.parse(Excon.get(url).body)
      end
    end
  end
end
