require 'spaceship'
require_relative 'module'

module Produce
  class CloudContainer
    def create(options, _args)
      login

      container_identifier = options.container_identifier || UI.input("iCloud Container identifier: ")

      if container_exists?(container_identifier)
        UI.success("[DevCenter] iCloud Container '#{options.container_name} (#{options.container_identifier})' already exists, nothing to do on the Dev Center")
        # Nothing to do here
      else
        container_name = options.container_name || container_identifier.gsub('.', ' ')

        UI.success("Creating new iCloud Container '#{container_name}' with identifier '#{container_identifier}' on the Apple Dev Center")

        container = Spaceship.cloud_container.create!(identifier: container_identifier, name: container_name)

        if container.name != container_name
          UI.important("Your container name includes non-ASCII characters, which are not supported by the Apple Developer Portal.")
          UI.important("To fix this a unique (internal) name '#{container.name}' has been created for you.")
        end

        UI.message("Created iCloud Container #{container.cloud_container}")
        UI.user_error!("Something went wrong when creating the new iCloud Container - it's not listed in the iCloud Container list") unless container_exists?(container_identifier)
        UI.success("Finished creating new iCloud Container '#{container_name}' on the Dev Center")
      end

      return true
    end

    def associate(_options, args)
      login

      if !app_exists?
        UI.message("[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist, nothing to associate with the containers")
      else
        app = Spaceship.app.find(app_identifier)
        UI.user_error!("Something went wrong when fetching the app - it's not listed in the apps list") if app.nil?

        new_containers = []

        UI.message("Validating containers before association")

        args.each do |container_identifier|
          if !container_exists?(container_identifier)
            UI.message("[DevCenter] iCloud Container '#{container_identifier}' does not exist, please create it first, skipping for now")
          else
            new_containers.push(Spaceship.cloud_container.find(container_identifier))
          end
        end

        UI.message("Finalising association with #{new_containers.count} containers")
        app.associate_cloud_containers(new_containers)
        UI.success("Done!")
      end

      return true
    end

    def login
      UI.message("Starting login with user '#{Produce.config[:username]}'")
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
      UI.message("Successfully logged in")
    end

    def app_identifier
      Produce.config[:app_identifier].to_s
    end

    def container_exists?(identifier)
      Spaceship.cloud_container.find(identifier) != nil
    end

    def app_exists?
      Spaceship.app.find(app_identifier) != nil
    end
  end
end
