require 'excon'

module FastlaneCore
  # Verifies, the user runs the latest version of this gem
  class UpdateChecker
    # This web service is fully open source: https://github.com/fastlane/refresher
    UPDATE_URL = "https://fastlane-refresher.herokuapp.com/"

    def self.start_looking_for_update(gem_name)
      return if Helper.is_test?
      return if ENV["FASTLANE_SKIP_UPDATE_CHECK"]

      @start_time = Time.now
      
      Thread.new do
        begin
          server_results[gem_name] = fetch_latest(gem_name)
        rescue
        end
      end
    end

    def self.server_results
      @@results ||= {}
    end

    def self.update_available?(gem_name, current_version)
      latest = server_results[gem_name]
      return (latest and Gem::Version.new(latest) > Gem::Version.new(current_version))
    end

    def self.show_update_status(gem_name, current_version)
      fork do
        begin
          finished_running(gem_name)
        rescue
           # we don't want to show a stack trace if something goes wrong
        end
      end

      if update_available?(gem_name, current_version)
        show_update_message(gem_name, current_version)
      end
    end

    def self.show_update_message(gem_name, current_version)
      available = server_results[gem_name]
      puts ""
      puts '#######################################################################'.green
      puts "# #{gem_name} #{available} is available. You are on #{current_version}.".green
      puts "# It is recommended to use the latest version.".green
      puts "# Update using 'sudo gem update #{gem_name.downcase}'.".green
      puts "# To see what's new, open https://github.com/KrauseFx/#{gem_name}/releases.".green
      puts '#######################################################################'.green
    end

    def self.fetch_latest(gem_name)
      url = UPDATE_URL + gem_name
      url += "?ci=1" if Helper.is_ci?
      JSON.parse(Excon.post(url).body).fetch("version", nil)
    end

    def self.finished_running(gem_name)
      time = (Time.now - @start_time).to_i

      url = UPDATE_URL + "time/#{gem_name}"
      url += "?time=#{time}"
      url += "&ci=1" if Helper.is_ci?
      Excon.post(url)
    end
  end
end