require 'spaceship'

module Produce
  class ItunesConnect
    
    def run
      login
      create_new_app
    end

    def create_new_app
      if app_exists?
        Helper.log.info "App '#{Produce.config[:app_name]}' exists already, nothing to do on iTunes Connect".green
        # Nothing to do here
      else
        Helper.log.info "Creating new app '#{Produce.config[:app_name]}' on iTunes Connect".green

        Spaceship::Tunes::Application.create!(name: Produce.config[:app_name], 
                                              primary_language: Produce.config[:primary_language],
                                              version: Produce.config[:version], 
                                              sku: Produce.config[:sku], 
                                              bundle_id: Produce.config[:bundle_identifier])

        raise "Something went wrong when creating the new app - it's not listed in the App's list" unless app_exists?

        Helper.log.info "Successfully created new app '#{Produce.config[:app_name]}' on iTC. Setting up the initial information now.".green

        Helper.log.info "Finished creating new app '#{Produce.config[:app_name]}' on iTunes Connect".green
      end

      return fetch_app.apple_id
    end

    private

      def fetch_app
        Spaceship::Application.find(Produce.config[:bundle_identifier])
      end

      def app_exists?
        Spaceship::Application.find(Produce.config[:bundle_identifier]) != nil
      end

      def wildcard_bundle?
        return Produce.config[:bundle_identifier].end_with?("*")
      end

      def login
        Spaceship::Tunes.login(Produce.config[:username], nil)
      end

  end
end
