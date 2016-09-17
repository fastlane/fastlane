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

      UI.message("Login to iTunes Connect (#{config[:username]})")
      Spaceship::Tunes.login(config[:username])
      Spaceship::Tunes.select_team
      UI.message("Login successful")
    end

    # The app object we're currently using
    def app
      @apple_id ||= fetch_app_id

      @app ||= Spaceship::Application.find(@apple_id)
      unless @app
        UI.user_error!("Could not find app with #{(config[:apple_id] || config[:app_identifier])}")
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
        UI.user_error!("Couldn't find app '#{config[:app_identifier]}' on the account of '#{config[:username]}' on iTunes Connect") unless @app
        app_id ||= @app.apple_id
      end

      app_id ||= UI.input("Could not automatically find the app ID, please enter it here (e.g. 956814360): ")

      return app_id
    end

    def fetch_app_identifier
      result = config[:app_identifier]
      result ||= FastlaneCore::IpaFileAnalyser.fetch_app_identifier(config[:ipa])
      result ||= UI.input("Please enter the app's bundle identifier: ")
      UI.verbose("App identifier (#{result})")
      return result
    end
  end
end
