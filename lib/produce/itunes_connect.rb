require 'spaceship'

module Produce
  class ItunesConnect
    
    def run
      @full_bundle_identifier = app_identifier
      @full_bundle_identifier.gsub!('*', Produce.config[:bundle_identifier_suffix].to_s) if wildcard_bundle?

      Spaceship::Tunes.login(Produce.config[:username], nil)

      create_new_app
    end

    def create_new_app
      application = fetch_application
      if application
        Helper.log.info "[iTC] App '#{Produce.config[:app_name]}' already exists (#{application.apple_id}), nothing to do on iTunes Connect".green
        # Nothing to do here
      else
        Helper.log.info "Creating new app '#{Produce.config[:app_name]}' on iTunes Connect".green

        Produce.config[:bundle_identifier_suffix] = '' unless wildcard_bundle?

        Spaceship::Tunes::Application.create!(name: Produce.config[:app_name], 
                                              primary_language: language,
                                              version: Produce.config[:app_version], 
                                              sku: Produce.config[:sku].to_s, # might be an int
                                              bundle_id: app_identifier, 
                                              bundle_id_suffix: Produce.config[:bundle_identifier_suffix],
                                              company_name: Produce.config[:company_name])
        application = fetch_application
        raise "Something went wrong when creating the new app - it's not listed in the App's list" unless application

        Helper.log.info "Successfully created new app '#{Produce.config[:app_name]}' on iTunes Connect with ID #{application.apple_id}".green
      end

      return Spaceship::Application.find(@full_bundle_identifier).apple_id
    end

    private
      def fetch_application
        Spaceship::Application.find(@full_bundle_identifier)
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
          raise "Please enter one of available languages: #{AvailableDefaultLanguages.all_languages}".red
        end

        return @language
      end
  end
end
