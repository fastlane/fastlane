require 'spaceship'
require 'babosa'

module Produce
  class DeveloperCenter

    def run
      login
      create_new_app
    end

    def create_new_app
      ENV["CREATED_NEW_APP_ID"] = Time.now.to_i.to_s

      if app_exists?
        Helper.log.info "[DevCenter] App '#{Produce.config[:app_name]}' already exists, nothing to do on the Dev Center".green
        ENV["CREATED_NEW_APP_ID"] = nil
        # Nothing to do here
      else
        app_name = valid_name_for(Produce.config[:app_name])
        Helper.log.info "Creating new app '#{app_name}' on the Apple Dev Center".green
        
        app = Spaceship.app.create!(bundle_id: app_identifier,
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

    def app_identifier
      Produce.config[:app_identifier].to_s
    end

    private
      def app_exists?
        Spaceship.app.find(app_identifier) != nil
      end

      def login
        Spaceship.login(Produce.config[:username], nil)
        Spaceship.select_team
      end
  end
end
