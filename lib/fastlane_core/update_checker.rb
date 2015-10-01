require 'excon'
require 'digest'

module FastlaneCore
  # Verifies, the user runs the latest version of this gem
  class UpdateChecker
    # This web service is fully open source: https://github.com/fastlane/refresher
    UPDATE_URL = "https://fastlane-refresher.herokuapp.com/"

    def self.start_looking_for_update(gem_name)
      return if Helper.is_test?
      return if ENV["FASTLANE_SKIP_UPDATE_CHECK"]

      @start_time = Time.now

      url = generate_fetch_url(gem_name)
      Thread.new do
        begin
          server_results[gem_name] = fetch_latest(url)
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

    # Generate the URL on the main thread (since we're switching directory)
    def self.generate_fetch_url(gem_name)
      url = UPDATE_URL + gem_name
      params = {}
      params["ci"] = "1" if Helper.is_ci?
      params["p_hash"] = p_hash if p_hash
      url += "?" + URI.encode_www_form(params) if params.count > 0
      return url
    end

    def self.fetch_latest(url)
      JSON.parse(Excon.post(url).body).fetch("version", nil)
    end

    def self.finished_running(gem_name)
      time = (Time.now - @start_time).to_i

      url = UPDATE_URL + "time/#{gem_name}"
      url += "?time=#{time}"
      url += "&ci=1" if Helper.is_ci?
      Excon.post(url)
    end

    # To not count the same projects multiple time for the number of launches
    # More information: https://github.com/fastlane/refresher
    # Use the `FASTLANE_OPT_OUT_USAGE` variable to opt out
    # The resulting value is e.g. ce12f8371df11ef6097a83bdf2303e4357d6f5040acc4f76019489fa5deeae0d
    def self.p_hash
      return nil if ENV["FASTLANE_OPT_OUT_USAGE"]
      require 'credentials_manager'
      value = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
      return Digest::SHA256.hexdigest("p" + value + "fastlan3_SAlt") if value # hashed + salted the bundle identifier
      return nil
    rescue
      return nil
    end
  end
end
