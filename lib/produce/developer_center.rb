require 'spaceship'
require 'babosa'

module Produce
  class DeveloperCenter

    def run(config)
      @config = config
      login
      create_new_app
    end

    def create_new_app
      ENV["CREATED_NEW_APP_ID"] = Time.now.to_i.to_s

      if app_exists?
        Helper.log.info "App '#{@config[:app_name]}' already exists, nothing to do on the Dev Center".green
        ENV["CREATED_NEW_APP_ID"] = nil
        # Nothing to do here
      else
        app_name = valid_name_for(@config[:app_name])
        Helper.log.info "Creating new app '#{app_name}' on the Apple Dev Center".green
        
        app = Spaceship.app.create!(bundle_id: @config[:bundle_identifier].to_s, 
                                         name: app_name)

        Helper.log.info "Created app #{app.app_id}"
        
        raise "Something went wrong when creating the new app - it's not listed in the apps list" unless app_exists?

        ENV["CREATED_NEW_APP_ID"] = Time.now.to_i.to_s

        Helper.log.info "Finished creating new app '#{app_name}' on the Dev Center".green
      end

      return true
    end

    def valid_name_for(input)
      latinazed = input.to_slug.transliterate.to_s # remove accents
      latinazed.gsub(/[^0-9A-Za-z\d\s]/, '') # remove non-valid characters
    end

    private
      def app_exists?
        Spaceship.app.find(@config[:bundle_identifier].to_s) != nil
      end

      def login
        user = ENV["CERT_USERNAME"] || ENV["DELIVER_USER"] || CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
        manager = CredentialsManager::PasswordManager.shared_manager(user)

        ENV["FASTLANE_TEAM_NAME"] ||= ENV['PRODUCE_TEAM_NAME']

        Spaceship.login(user, manager.password)
        Spaceship.select_team
      end
  end
end
