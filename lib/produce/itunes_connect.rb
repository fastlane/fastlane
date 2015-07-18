require 'spaceship'

module Produce
  class ItunesConnect
    
    def run
      @full_bundle_identifier = Produce.config[:bundle_identifier]
      @full_bundle_identifier.gsub!('*', Produce.config[:bundle_identifier_suffix].to_s) if wildcard_bundle?

      Spaceship::Tunes.login(Produce.config[:username], nil)

      create_new_app
    end

    def create_new_app
      application = fetch_application
      if application
        Helper.log.info "App '#{Produce.config[:app_name]}' exists already (#{application.apple_id}), nothing to do on iTunes Connect".green
        # Nothing to do here
      else
        Helper.log.info "Creating new app '#{Produce.config[:app_name]}' on iTunes Connect".green

        Produce.config[:bundle_identifier_suffix] = '' unless wildcard_bundle?

        Spaceship::Tunes::Application.create!(name: Produce.config[:app_name], 
                                              primary_language: Produce.config[:primary_language],
                                              version: Produce.config[:initial_version], 
                                              sku: Produce.config[:sku], 
                                              bundle_id: Produce.config[:bundle_identifier], 
                                              bundle_id_suffix: Produce.config[:bundle_identifier_suffix])
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
        return Produce.config[:bundle_identifier].end_with?("*")
      end
  end
end
