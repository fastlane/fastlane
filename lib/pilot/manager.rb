require 'fastlane_core'

module Pilot
  class Manager
    def run(options)
      @config = options
      login

      config[:apple_id] ||= fetch_app_id

      Helper.log.info "Ready to upload new build to TestFlight (App: #{config[:apple_id]})...".green

      package_path = PackageBuilder.new.generate(apple_id: config[:apple_id], 
                                                 ipa_path: config[:ipa],
                                             package_path: "/tmp") # TODO: Config

      result = FastlaneCore::ItunesTransporter.new.upload(config[:apple_id], package_path)
      if result
        Helper.log.info "Successfully uploaded the new binary to iTunes Connect"
      else
        raise "Error uploading ipa file, more information see above".red
      end
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

    def app
      unless (@app ||= Spaceship::Application.find(config[:apple_id] || config[:app_identifier]))
        raise "Could not find app with #{(config[:apple_id] || config[:app_identifier])}"
      end
      return @app
    end

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