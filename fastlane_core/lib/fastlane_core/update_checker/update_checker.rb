require 'excon'
require 'digest'

require 'fastlane_core/update_checker/changelog'

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
      @results ||= {}
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
      puts "# To see what's new, open https://github.com/fastlane/#{gem_name}/releases.".green if ENV["FASTLANE_HIDE_CHANGELOG"]
      if Random.rand(5) == 1
        puts '#######################################################################'.green
        puts "# Run `sudo gem cleanup` from time to time to speed up fastlane".green
      end
      puts '#######################################################################'.green
      Changelog.show_changes(gem_name, current_version) unless ENV["FASTLANE_HIDE_CHANGELOG"]
    end

    # Generate the URL on the main thread (since we're switching directory)
    def self.generate_fetch_url(gem_name)
      url = UPDATE_URL + gem_name
      params = {}
      params["ci"] = "1" if Helper.is_ci?

      project_hash = p_hash
      params["p_hash"] = project_hash if project_hash

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

    # (optional) Returns the app identifier for the current tool
    def self.ios_app_identifier
      # ARGV example:
      # ["-a", "com.krausefx.app", "--team_id", "5AA97AAHK2"]
      ARGV.each_with_index do |current, index|
        if current == "-a" || current == "--app_identifier"
          return ARGV[index + 1] if ARGV.count > index
        end
      end

      ["FASTLANE", "DELIVER", "PILOT", "PRODUCE", "PEM", "SIGH", "SNAPSHOT", "MATCH"].each do |current|
        return ENV["#{current}_APP_IDENTIFIER"] if ENV["#{current}_APP_IDENTIFIER"]
      end

      return nil
    rescue
      nil # we don't want this method to cause a crash
    end

    # To not count the same projects multiple time for the number of launches
    # More information: https://github.com/fastlane/refresher
    # Use the `FASTLANE_OPT_OUT_USAGE` variable to opt out
    # The resulting value is e.g. ce12f8371df11ef6097a83bdf2303e4357d6f5040acc4f76019489fa5deeae0d
    def self.p_hash
      return nil if ENV["FASTLANE_OPT_OUT_USAGE"]
      require 'credentials_manager'

      value = nil
      value ||= self.ios_app_identifier
      value ||= CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
      unless value
        value = CredentialsManager::AppfileConfig.try_fetch_value(:package_name)
        value = "android_project_#{value}" if value # if the iOS and Android app share the same app identifier
      end

      if value
        return Digest::SHA256.hexdigest("p#{value}fastlan3_SAlt") # hashed + salted the bundle identifier
      end

      return nil
    rescue
      return nil
    end
  end
end
