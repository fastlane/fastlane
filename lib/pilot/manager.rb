require "fastlane_core"

module Pilot
  class Manager
    def run(options)
      return if @config # to not login multiple times
      @config = options
      login

      config[:apple_id] ||= fetch_app_id
    end

    def login
      user = config[:username]
      user ||= ENV["DELIVER_USERNAME"]
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
      CredentialsManager::PasswordManager.shared_manager(user) if user

      Helper.log.info "Login to iTunes Connect"
      Spaceship::Tunes.login(user, CredentialsManager::PasswordManager.shared_manager(user).password)
      Helper.log.info "Login successful"
    end

    # The app object we're currently using
    def app
      unless (@app ||= Spaceship::Application.find(config[:apple_id] || config[:app_identifier]))
        raise "Could not find app with #{(config[:apple_id] || config[:app_identifier])}"
      end
      return @app
    end

    # Access the current configuration 
    def config
      @config
    end

    # Config Related
    ################

    def fetch_app_id
      return config[:apple_id] if config[:apple_id]
      config[:app_identifier] = fetch_app_identifier

      if config[:app_identifier]
        app_id ||= app.apple_id
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
  end
end