require 'spaceship'
require 'spaceship/tunes/tunes'
require_relative 'module'
require_relative 'available_default_languages'

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
        UI.success("App '#{Produce.config[:app_identifier]}' already exists (#{application.apple_id}), nothing to do on App Store Connect")
        # Nothing to do here
      else
        UI.success("Creating new app '#{Produce.config[:app_name]}' on App Store Connect")

        Produce.config[:bundle_identifier_suffix] = '' unless wildcard_bundle?
        generated_app = Spaceship::Tunes::Application.create!(name: Produce.config[:app_name],
                                                              primary_language: language,
                                                              sku: Produce.config[:sku].to_s, # might be an int
                                                              bundle_id: app_identifier,
                                                              bundle_id_suffix: Produce.config[:bundle_identifier_suffix],
                                                              company_name: Produce.config[:company_name],
                                                              platform: Produce.config[:platform],
                                                              itunes_connect_users: Produce.config[:itc_users])

        UI.crash!("Something went wrong when creating the new app on iTC") if generated_app["adamId"].to_s.empty?

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
        application.ensure_version!(Produce.config[:app_version], platform: Produce.config[:platform]) if Produce.config[:app_version]

        UI.success("Successfully created new app '#{Produce.config[:app_name]}' on App Store Connect with ID #{application.apple_id}")
      end

      return Spaceship::Tunes::Application.find(@full_bundle_identifier, mac: Produce.config[:platform] == "osx").apple_id
    end

    private

    def fetch_application
      Spaceship::Tunes::Application.find(@full_bundle_identifier)
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

      converted = Spaceship::Tunes::LanguageConverter.from_itc_readable_to_itc(@language)
      @language = converted if converted # overwrite it with the actual value

      unless AvailableDefaultLanguages.all_languages.include?(@language)
        UI.user_error!("Please enter one of available languages: #{AvailableDefaultLanguages.all_languages}")
      end

      return @language
    end
  end
end
