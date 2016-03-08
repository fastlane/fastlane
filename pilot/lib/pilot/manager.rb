require "fastlane_core"

module Pilot
  class Manager
    def start(options)
      return if @config # to not login multiple times
      @config = options
      login
    end

    def login
      config[:username] ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      Helper.log.info "Login to iTunes Connect (#{config[:username]})"
      Spaceship::Tunes.login(config[:username])
      Spaceship::Tunes.select_team
      Helper.log.info "Login successful"
    end

    # The app object we're currently using
    def app
      @apple_id ||= fetch_app_id

      @app ||= Spaceship::Application.find(@apple_id)
      unless @app
        raise "Could not find app with #{(config[:apple_id] || config[:app_identifier])}"
      end
      return @app
    end

    # Access the current configuration
    attr_reader :config

    # Config Related
    ################

    def fetch_app_id
      return @apple_id if @apple_id
      config[:app_identifier] = fetch_app_identifier

      if config[:app_identifier]
        @app ||= Spaceship::Application.find(config[:app_identifier])
        raise "Couldn't find app '#{config[:app_identifier]}' on the account of '#{config[:username]}' on iTunes Connect".red unless @app
        app_id ||= @app.apple_id
      end

      app_id ||= ask("Could not automatically find the app ID, please enter it here (e.g. 956814360): ")

      return app_id
    end

    def fetch_app_identifier
      result = config[:app_identifier]
      result ||= FastlaneCore::IpaFileAnalyser.fetch_app_identifier(config[:ipa])
      result ||= ask("Please enter the app's bundle identifier: ")
      return result
    end

    # Perform the app_id lookup based solely on the passed parameters
    # nil if app_id is not configured.
    def find_app_id_no_prompt
      return @apple_id if @apple_id
      app_filter = (config[:apple_id] || config[:app_identifier])
      if app_filter
        @app = Spaceship::Application.find(app_filter)
        raise "Couldn't find app with '#{app_filter}'" unless @app
        @apple_id = @app.apple_id
        return @apple_id
      end
    end
  end
end
