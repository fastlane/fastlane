require 'credentials_manager/appfile_config'

require 'fastlane_core/print_table'
require 'spaceship'
require 'spaceship/tunes/tunes'
require 'spaceship/tunes/members'
require 'spaceship/test_flight'
require 'fastlane_core/ipa_file_analyser'
require_relative 'module'

module Pilot
  class Manager
    def start(options)
      return if @config # to not login multiple times
      @config = options
      login
    end

    def login
      config[:username] ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      UI.message("Login to App Store Connect (#{config[:username]})")
      Spaceship::Tunes.login(config[:username])
      Spaceship::Tunes.select_team(team_id: config[:team_id], team_name: config[:team_name])
      UI.message("Login successful")
    end

    # The app object we're currently using
    def app
      @apple_id ||= fetch_app_id

      @app ||= Spaceship::Tunes::Application.find(@apple_id)
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
        @app ||= Spaceship::Tunes::Application.find(config[:app_identifier])
        UI.user_error!("Couldn't find app '#{config[:app_identifier]}' on the account of '#{config[:username]}' on App Store Connect") unless @app
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

    def fetch_app_platform(required: true)
      result = config[:app_platform]
      result ||= FastlaneCore::IpaFileAnalyser.fetch_app_platform(config[:ipa]) if config[:ipa]
      if required
        result ||= UI.input("Please enter the app's platform (appletvos, ios, osx): ")
        UI.user_error!("App Platform must be ios, appletvos, or osx") unless ['ios', 'appletvos', 'osx'].include?(result)
        UI.verbose("App Platform (#{result})")
      end
      return result
    end
  end
end
