require 'open-uri'

module FastlaneCore
  # Verifies, the user runs the latest version of this gem
  class UpdateChecker

    # This web service is fully open source: https://github.com/fastlane/refresher
    UPDATE_URL = "https://fastlane-refresher.herokuapp.com/"

    def self.start_looking_for_update(gem_name)
      return if Helper.is_test?
      return if ENV["FASTLANE_SKIP_UPDATE_CHECK"]
      
      Thread.new do
        begin
          server_results[gem_name] = fetch_latest(gem_name)
        rescue
        end
      end
    end

    def self.show_update_status(gem_name, current_version)
      latest = server_results[gem_name]
      if latest and Gem::Version.new(latest) > Gem::Version.new(current_version)
        show_update_message(gem_name, latest, current_version)
      end
    end

    def self.show_update_message(gem_name, available, current_version)
      v = fetch_latest(gem_name)
      puts ""
      puts '#######################################################################'.green
      puts "# #{gem_name} #{available} is available. You are on #{current_version}.".green
      puts "# It is recommended to use the latest version.".green
      puts "# Update using 'sudo gem update #{gem_name.downcase}'.".green
      puts "# To see what's new, open https://github.com/KrauseFx/#{gem_name}/releases.".green
      puts '#######################################################################'.green
    end

    def self.server_results
      @@results ||= {}
    end

    # Legacy Code:
    # 
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

    # Relevant code
    def self.fetch_latest(gem_name)
      url = UPDATE_URL + gem_name
      url += "?ci=1" if Helper.is_ci?
      JSON.parse(open(url).read)["version"]
    end
  end
end