require 'fastlane_core/itunes_connect/itunes_connect'
require 'spaceship'

module Produce
  class ItunesConnect
    
    def run(config)
      @config = config
      login
      create_new_app
    end

    def create_new_app
      if app_exists?
        Helper.log.info "App '#{@config[:app_name]}' exists already, nothing to do on iTunes Connect".green
        # Nothing to do here
      else
        Helper.log.info "Creating new app '#{@config[:app_name]}' on iTunes Connect".green

        app_name = @config[:app_name]
        version = @config[:version]
        sku = @config[:sku]
        bundle_id = @config[:bundle_identifier]

        # Invoque spaceship
        Spaceship::Tunes::Application.create!(name: app_name, 
                                              version: version, 
                                              sku: sku, 
                                              bundle_id: bundle_id)

        raise "Something went wrong when creating the new app - it's not listed in the App's list" unless app_exists?

        Helper.log.info "Finished creating new app '#{@config[:app_name]}' on iTunes Connect".green
      end

      return true
    end

    private

      def app_exists?
        Spaceship::Application.find(@config[:bundle_identifier]) != nil
      end

      def wildcard_bundle?
        return @config[:bundle_identifier].end_with?("*")
      end

      def login
        user = ENV["CERT_USERNAME"] || ENV["DELIVER_USER"] || CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
        manager = CredentialsManager::PasswordManager.shared_manager(user)

        ENV["FASTLANE_TEAM_NAME"] ||= ENV['PRODUCE_TEAM_NAME']

        Spaceship::Tunes.login(user, manager.password)
      end

  end
end
