require 'spaceship'

module Produce
  class DeveloperCenter
    def run
      login
      create_new_app
    end

    def create_new_app
      ENV["CREATED_NEW_APP_ID"] = Time.now.to_i.to_s

      if app_exists?
        UI.success "[DevCenter] App '#{Produce.config[:app_identifier]}' already exists, nothing to do on the Dev Center"
        ENV["CREATED_NEW_APP_ID"] = nil
        # Nothing to do here
      else
        app_name = Produce.config[:app_name]
        UI.message "Creating new app '#{app_name}' on the Apple Dev Center"

        app = Spaceship.app.create!(bundle_id: app_identifier,
                                         name: app_name,
                                         mac: Produce.config[:platform] == "osx")

        if app.name != Produce.config[:app_name]
          UI.important("Your app name includes non-ASCII characters, which are not supported by the Apple Developer Portal.")
          UI.important("To fix this a unique (internal) name '#{app.name}' has been created for you. Your app's real name '#{Produce.config[:app_name]}'")
          UI.important("will still show up correctly on iTunes Connect and the App Store.")
        end

        UI.message "Created app #{app.app_id}"

        UI.crash!("Something went wrong when creating the new app - it's not listed in the apps list") unless app_exists?

        ENV["CREATED_NEW_APP_ID"] = Time.now.to_i.to_s

        UI.success "Finished creating new app '#{app_name}' on the Dev Center"
      end

      return true
    end

    def app_identifier
      Produce.config[:app_identifier].to_s
    end

    private

    def app_exists?
      Spaceship.app.find(app_identifier, mac: Produce.config[:platform] == "osx") != nil
    end

    def login
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
    end
  end
end
