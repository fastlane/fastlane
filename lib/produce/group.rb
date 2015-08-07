require 'spaceship'
require 'babosa'

module Produce
  class Group
    def create(options, args)
      login

      ENV["CREATED_NEW_GROUP_ID"] = Time.now.to_i.to_s

      if app_group_exists? group_identifier
        Helper.log.info "[DevCenter] Group '#{Produce.config[:group_name]}' already exists, nothing to do on the Dev Center".green
        ENV["CREATED_NEW_GROUP_ID"] = nil
        # Nothing to do here
      else
        group_name = valid_name_for(Produce.config[:group_name])
        Helper.log.info "Creating new app group '#{group_name}' on the Apple Dev Center".green

        group = Spaceship.app_group.create!(group_id: group_identifier,
                                          name: group_name)

        Helper.log.info "Created group #{group.app_group_id}"

        raise "Something went wrong when creating the new app group - it's not listed in the app groups list" unless app_group_exists? group_identifier

        ENV["CREATED_NEW_GROUP_ID"] = Time.now.to_i.to_s

        Helper.log.info "Finished creating new app group '#{group_name}' on the Dev Center".green
      end

      return true
    end

    def associate(options, args)
      login

      if !app_exists?
        Helper.log.info "[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist, nothing to associate with the groups".red
      else
        app = Spaceship.app.find(app_identifier)
        raise "Something went wrong when fetching the app - it's not listed in the apps list" unless app != nil

        new_groups = Array.new

        Helper.log.info "Validating groups before association"

        for group_identifier in args
          if !app_group_exists? group_identifier
            Helper.log.info "[DevCenter] App group '#{group_identifier}' does not exist, please create it first, skipping for now".red
          else
            new_groups.push(Spaceship.app_group.find(group_identifier))
          end
        end

        Helper.log.info "Finalising association with #{new_groups.count} groups"
        app.associate_groups(new_groups)
        Helper.log.info "Done!".green
      end

      return true
    end

    def login
      Helper.log.info "Starting login"
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
      Helper.log.info "Successfully logged in"
    end

    def group_identifier
      Produce.config[:group_identifier].to_s
    end

    def app_identifier
      Produce.config[:app_identifier].to_s
    end

    def app_group_exists? (identifier)
      Spaceship.app_group.find(identifier) != nil
    end

    def app_exists?
      Spaceship.app.find(app_identifier) != nil
    end

    def valid_name_for(input)
      latinazed = input.to_slug.transliterate.to_s # remove accents
      latinazed.gsub(/[^0-9A-Za-z\d\s]/, '') # remove non-valid characters
    end
  end
end
