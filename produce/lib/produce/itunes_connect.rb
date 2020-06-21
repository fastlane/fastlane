require 'spaceship'
require 'spaceship/tunes/tunes'
require 'fastlane_core/languages'
require_relative 'module'

module Produce
  class ItunesConnect
    def run
      @full_bundle_identifier = app_identifier
      @full_bundle_identifier.gsub!('*', Produce.config[:bundle_identifier_suffix].to_s) if wildcard_bundle?

      Spaceship::Tunes.login(Produce.config[:username], nil)
      Spaceship::Tunes.client.select_team

      create_new_app
    end

    def create_new_app
      application = fetch_application
      if application
        UI.success("App '#{Produce.config[:app_identifier]}' already exists (#{application.id}), nothing to do on App Store Connect")
        # Nothing to do here
      else
        UI.success("Creating new app '#{Produce.config[:app_name]}' on App Store Connect")

        platforms = Produce.config[:platforms] || [Produce.config[:platform]]

        platforms = platforms.map do |platform|
          Spaceship::ConnectAPI::Platform.map(platform)
        end

        # Produce.config[:company_name]
        # Produce.config[:itc_users]
        application = Spaceship::ConnectAPI::App.create(
          name: Produce.config[:app_name],
          version_string: Produce.config[:app_version] || "1.0",
          sku: Produce.config[:sku].to_s,
          primary_locale: language,
          bundle_id: app_identifier,
          platforms: platforms
        )

        application = fetch_application
        counter = 0
        while application.nil?
          counter += 1
          UI.crash!("Couldn't find newly created app on App Store Connect - please check the website for more information") if counter == 200

          # Since 2016-08-10 App Store Connect takes some time to actually list the newly created application
          # We have no choice but to poll to see if the newly created app is already available
          UI.message("Waiting for the newly created application to be available on App Store Connect...")
          sleep(15)
          application = fetch_application
        end

        UI.crash!("Something went wrong when creating the new app - it's not listed in the App's list") unless application

        UI.message("Ensuring version number")
        platforms.each do |platform|
          application.ensure_version!(Produce.config[:app_version], platform: platform) if Produce.config[:app_version]
        end

        UI.success("Successfully created new app '#{Produce.config[:app_name]}' on App Store Connect with ID #{application.id}")
      end

      return application.id
    end

    private

    def platform
      (Produce.config[:platforms] || []).first || Produce.config[:platform]
    end

    def fetch_application
      Spaceship::ConnectAPI::App.find(@full_bundle_identifier)
    end

    def wildcard_bundle?
      return app_identifier.end_with?("*")
    end

    def app_identifier
      Produce.config[:app_identifier].to_s
    end

    # Makes sure to get the value for the language
    # Instead of using the user's value `UK English` spaceship should send
    # `English_UK` to the server
    def language
      @language = Produce.config[:language]

      unless FastlaneCore::Languages::ALL_LANGUAGES.include?(@language)
        UI.user_error!("Please enter one of available languages: #{FastlaneCore::Languages::ALL_LANGUAGES}")
      end

      return @language
    end
  end
end
