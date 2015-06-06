require 'spaceship'

module Produce
  class DeveloperCenter

    def run(config)
      @config = config
      login
      create_new_app
    end

    def create_new_app
      ENV["CREATED_NEW_APP_ID"] = Time.now.to_i

      if app_exists?
        Helper.log.info "App '#{@config[:app_name]}' already exists, nothing to do on the Dev Center".green
        ENV["CREATED_NEW_APP_ID"] = nil
        # Nothing to do here
      else
        app_name = valid_name_for(@config[:app_name])
        Helper.log.info "Creating new app '#{app_name}' on the Apple Dev Center".green
        
        app = Spaceship.app.create!(bundle_id: @config[:bundle_identifier].to_s, 
                                         name: app_name)

        Helper.log.info "Created app #{app}"
        require 'pry'; binding.pry
        
        raise "Something went wrong when creating the new app - it's not listed in the apps list" unless app_exists?

        ENV["CREATED_NEW_APP_ID"] = Time.now.to_s

        Helper.log.info "Finished creating new app '#{app_name}' on the Dev Center".green
      end

      return true
    end


    private
      def app_exists?
        Spaceship.app.find(@config[:bundle_identifier].to_s) != nil
      end

      def login
        user = ENV["CERT_USERNAME"] || ENV["DELIVER_USER"] || CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
        manager = CredentialsManager::PasswordManager.shared_manager(user)

        Spaceship.login(user, manager.password)
      end
  end
end
