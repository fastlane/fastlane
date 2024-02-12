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
    def start(options, should_login: true)
      return if @config # to not login multiple times
      @config = options

      # we will always start with App Store Connect API login 'if possible'
      # else fallback to 'should_login' param for 'apple_id' login
      login if options[:api_key_path] || options[:api_key] || should_login
    end

    def login
      if (api_token = Spaceship::ConnectAPI::Token.from(hash: config[:api_key], filepath: config[:api_key_path]))
        UI.message("Creating authorization token for App Store Connect API")
        Spaceship::ConnectAPI.token = api_token
      elsif !Spaceship::ConnectAPI.token.nil?
        UI.message("Using existing authorization token for App Store Connect API")
      else
        config[:username] ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        # Username is now optional since addition of App Store Connect API Key
        # Force asking for username to prompt user if not already set
        config.fetch(:username, force_ask: true)

        UI.message("Login to App Store Connect (#{config[:username]})")
        Spaceship::ConnectAPI.login(config[:username], use_portal: false, use_tunes: true, tunes_team_id: config[:team_id], team_name: config[:team_name])
        UI.message("Login successful")
      end
    end

    # The app object we're currently using
    def app
      @app_id ||= fetch_app_id

      @app ||= Spaceship::ConnectAPI::App.get(app_id: @app_id)
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
      @app_id ||= config[:apple_id]
      return @app_id if @app_id
      config[:app_identifier] = fetch_app_identifier

      if config[:app_identifier]
        @app ||= Spaceship::ConnectAPI::App.find(config[:app_identifier])
        UI.user_error!("Couldn't find app '#{config[:app_identifier]}' on the account of '#{config[:username]}' on App Store Connect") unless @app
        @app_id ||= @app.id
      end

      @app_id ||= UI.input("Could not automatically find the app ID, please enter it here (e.g. 956814360): ")

      return @app_id
    end

    def fetch_app_identifier
      result = config[:app_identifier]
      result ||= FastlaneCore::IpaFileAnalyser.fetch_app_identifier(config[:ipa]) if config[:ipa]
      result ||= FastlaneCore::PkgFileAnalyser.fetch_app_identifier(config[:pkg]) if config[:pkg]
      result ||= UI.input("Please enter the app's bundle identifier: ")
      UI.verbose("App identifier (#{result})")
      return result
    end

    def fetch_app_platform(required: true)
      result = config[:app_platform]
      result ||= FastlaneCore::IpaFileAnalyser.fetch_app_platform(config[:ipa]) if config[:ipa]
      result ||= FastlaneCore::PkgFileAnalyser.fetch_app_platform(config[:pkg]) if config[:pkg]
      if required
        result ||= UI.input("Please enter the app's platform (appletvos, ios, osx, xros): ")
        UI.user_error!("App Platform must be ios, appletvos, osx, or xros") unless ['ios', 'appletvos', 'osx', 'xros'].include?(result)
        UI.verbose("App Platform (#{result})")
      end
      return result
    end
  end
end
