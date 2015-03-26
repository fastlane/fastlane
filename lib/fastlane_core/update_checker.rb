require 'open-uri'

module FastlaneCore
  # Verifies, the user runs the latest version of this gem
  class UpdateChecker

    # This web service is fully open source: https://github.com/fastlane/refresher
    UPDATE_URL = "https://fastlane-refresher.herokuapp.com/"

    # This method will check if the latest version is installed and show a warning if that's not the case
    def self.verify_latest_version(gem_name, current_version)
      return true unless self.update_available?(gem_name, current_version)

      v = fetch_latest(gem_name)
      puts '#######################################################################'.green
      puts "# #{gem_name} #{v} is available. You are on #{current_version}.".green
      puts "# It is recommended to use the latest version.".green
      puts "# Update using 'sudo gem update #{gem_name.downcase}'.".green
      puts "# To see what's new, open https://github.com/KrauseFx/#{gem_name}/releases.".green
      puts '#######################################################################'.green
      false
    end

    # Is a new official release available (this does not include pre-releases)
    def self.update_available?(gem_name, current_version)
      begin
        latest = fetch_latest(gem_name)
        if latest and Gem::Version.new(latest) > Gem::Version.new(current_version)
          return true
        end
      rescue => ex
        Helper.log.error("Could not check if '#{gem_name}' is up to date.")
      end
      return false
    end

    private
      def self.fetch_latest(gem_name)
        url = UPDATE_URL + gem_name
        JSON.parse(open(url).read)["version"]
      end
  end
end