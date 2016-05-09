require 'excon'

module FastlaneCore
  class Changelog
    class << self
      def show_changes(gem_name, current_version)
        self.releases(gem_name).each_with_index do |release, index|
          next unless Gem::Version.new(release['tag_name']) > Gem::Version.new(current_version)
          puts ""
          puts release['name'].green
          puts release['body']

          next unless index == 2
          puts ""
          puts "To see all new releases, open https://github.com/fastlane/#{gem_name}/releases".green
          break
        end
        puts "\nUpdate using 'sudo gem update #{gem_name.downcase}'".green
      rescue
        # Something went wrong, we don't care so much about this
      end

      def releases(gem_name)
        # We have to follow redirects, since some repos were moved
        # away into a separate org
        # Taken from https://github.com/excon/excon/issues/115#issuecomment-40647211
        Excon.defaults[:middlewares] << Excon::Middleware::RedirectFollower

        url = "https://api.github.com/repos/fastlane/#{gem_name}/releases"
        JSON.parse(Excon.get(url).body)
      end
    end
  end
end
