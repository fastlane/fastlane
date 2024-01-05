require 'spaceship'
require_relative 'module'

module Produce
  class Group
    def create(options, _args)
      login

      ENV["CREATED_NEW_GROUP_ID"] = Time.now.to_i.to_s

      group_identifier = options.group_identifier || UI.input("Group identifier: ")

      if app_group_exists?(group_identifier)
        UI.success("[DevCenter] Group '#{options.group_name} (#{options.group_identifier})' already exists, nothing to do on the Dev Center")
        ENV["CREATED_NEW_GROUP_ID"] = nil
        # Nothing to do here
      else
        group_name = options.group_name || group_identifier.split(".").map(&:capitalize).reverse.join(' ')

        UI.success("Creating new app group '#{group_name}' with identifier '#{group_identifier}' on the Apple Dev Center")

        group = Spaceship.app_group.create!(group_id: group_identifier,
                                            name: group_name)

        if group.name != group_name
          UI.important("Your group name includes non-ASCII characters, which are not supported by the Apple Developer Portal.")
          UI.important("To fix this a unique (internal) name '#{group.name}' has been created for you.")
        end

        UI.message("Created group #{group.app_group_id}")

        UI.user_error!("Something went wrong when creating the new app group - it's not listed in the app groups list") unless app_group_exists?(group_identifier)

        ENV["CREATED_NEW_GROUP_ID"] = Time.now.to_i.to_s

        UI.success("Finished creating new app group '#{group_name}' on the Dev Center")
      end

      return true
    end

    def associate(_options, args)
      login

      if !app_exists?
        UI.message("[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist, nothing to associate with the groups")
      else
        app = Spaceship.app.find(app_identifier)
        UI.user_error!("Something went wrong when fetching the app - it's not listed in the apps list") if app.nil?

        new_groups = []

        UI.message("Validating groups before association")

        args.each do |group_identifier|
          if !app_group_exists?(group_identifier)
            UI.message("[DevCenter] App group '#{group_identifier}' does not exist, please create it first, skipping for now")
          else
            new_groups.push(Spaceship.app_group.find(group_identifier))
          end
        end

        UI.message("Finalising association with #{new_groups.count} groups")
        app.associate_groups(new_groups)
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

    def app_group_exists?(identifier)
      Spaceship.app_group.find(identifier) != nil
    end

    def app_exists?
      Spaceship.app.find(app_identifier) != nil
    end
  end
end
