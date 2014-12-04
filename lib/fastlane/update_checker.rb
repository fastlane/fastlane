require 'open-uri'

module Fastlane
  # Verifies, the user runs the latest version of this gem
  class UpdateChecker
    # This method will check if the latest version is installed and show a warning if that's not the case
    def self.verify_latest_version
      if self.update_available?
        v = fetch_latest
        puts '#######################################################################'.green
        puts "# fastlane #{v} is available.".green
        puts "# It is recommended to use the latest version.".green
        puts "# Update using '(sudo) gem update fastlane'.".green
        puts "# To see what's new, open https://github.com/KrauseFx/fastlane/releases.".green
        puts '#######################################################################'.green
        return true
      end
      false
    end

    # Is a new official release available (this does not include pre-releases)
    def self.update_available?
      begin
        latest = fetch_latest
        if latest and Gem::Version.new(latest) > Gem::Version.new(current_version)
          return true
        end
      rescue Exception => ex
        Helper.log.error("Could not check if 'fastlane' is up to date.")
      end
      return false
    end

    # The currently used version of this gem
    def self.current_version
      Fastlane::VERSION
    end

    private
      def self.fetch_latest
        JSON.parse(open("http://rubygems.org/api/v1/gems/fastlane.json").read)["version"]
      end
  end
end