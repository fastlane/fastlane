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
      if Helper.bundler?
        puts "# Update using 'bundle update #{gem_name.downcase}'.".green
      else
        puts "# Update using 'sudo gem update #{gem_name.downcase}'.".green
      end
      puts "# To see what's new, open https://github.com/fastlane/#{gem_name}/releases.".green if ENV["FASTLANE_HIDE_CHANGELOG"]

      if Random.rand(5) == 1 && !Helper.bundler?
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

      project_hash = p_hash(ARGV, gem_name)
      params["p_hash"] = project_hash if project_hash
      params["platform"] = @platform if @platform # this has to be called after `p_hash`

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
    def self.ios_app_identifier(args)
      # args example: ["-a", "com.krausefx.app", "--team_id", "5AA97AAHK2"]
      args.each_with_index do |current, index|
        if current == "-a" || current == "--app_identifier"
          return args[index + 1] if args.count > index
        end
      end

      ["FASTLANE", "DELIVER", "PILOT", "PRODUCE", "PEM", "SIGH", "SNAPSHOT", "MATCH"].each do |current|
        return ENV["#{current}_APP_IDENTIFIER"] if ENV["#{current}_APP_IDENTIFIER"]
      end

      return CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
    rescue
      nil # we don't want this method to cause a crash
    end

    # (optional) Returns the app identifier for the current tool
    # supply and screengrab use different param names and env variable patterns so we have to special case here
    # example:
    #   supply --skip_upload_screenshots -a beta -p com.test.app should return com.test.app
    #   screengrab -a com.test.app should return com.test.app
    def self.android_app_identifier(args, gem_name)
      app_identifier = nil
      # args example: ["-a", "com.krausefx.app"]
      args.each_with_index do |current, index|
        if android_app_identifier_arg?(gem_name, current)
          app_identifier = args[index + 1] if args.count > index
          break
        end
      end

      app_identifier ||= ENV["SUPPLY_PACKAGE_NAME"] if ENV["SUPPLY_PACKAGE_NAME"]
      app_identifier ||= ENV["SCREENGRAB_APP_PACKAGE_NAME"] if ENV["SCREENGRAB_APP_PACKAGE_NAME"]
      app_identifier ||= CredentialsManager::AppfileConfig.try_fetch_value(:package_name)

      # Add Android prefix to prevent collisions if there is an iOS app with the same identifier
      app_identifier ? "android_project_#{app_identifier}" : nil
    rescue
      nil # we don't want this method to cause a crash
    end

    def self.android_app_identifier_arg?(gem_name, arg)
      return arg == "--package_name" ||
             arg == "--app_package_name" ||
             (arg == '-p' && gem_name == 'supply') ||
             (arg == '-a' && gem_name == 'screengrab')
    end

    # To not count the same projects multiple time for the number of launches
    # More information: https://github.com/fastlane/refresher
    # Use the `FASTLANE_OPT_OUT_USAGE` variable to opt out
    # The resulting value is e.g. ce12f8371df11ef6097a83bdf2303e4357d6f5040acc4f76019489fa5deeae0d
    def self.p_hash(args, gem_name)
      return nil if ENV["FASTLANE_OPT_OUT_USAGE"]
      require 'credentials_manager'

      # check if this is an android project first because some of the same params exist for iOS and Android tools
      app_identifier = android_app_identifier(args, gem_name)
      @platform = nil # since have a state in-between runs
      if app_identifier
        @platform = :android
      else
        app_identifier = ios_app_identifier(args)
        @platform = :ios if app_identifier
      end

      if app_identifier
        return Digest::SHA256.hexdigest("p#{app_identifier}fastlan3_SAlt") # hashed + salted the bundle identifier
      end

      return nil
    rescue
      return nil
    end
  end
end
