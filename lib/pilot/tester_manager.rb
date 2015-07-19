require "fastlane_core"

module Pilot
  class TesterManager < Manager
    @logged_in = false

    def login
      return if @logged_in

      super
      @logged_in = true
    end

    def tester_type_str(external)
      external ? "external" : "internal"
    end

    def describe_tester(tester)
      return if tester.nil?

      puts "First name: #{tester.first_name}".green
      puts "Last name: #{tester.last_name}".green
      puts "Email: #{tester.email}".green

      groups = tester.raw_data.get("groups")

      if groups && groups.length > 0
        group_names = groups.map { |group| group["name"]["value"] }
        puts "Groups: #{group_names.join(', ')}".green
      end

      latestInstalledDate = tester.raw_data.get("latestInstalledDate")
      if latestInstalledDate
        latest_installed_version = tester.raw_data.get("latestInstalledVersion")
        latest_installed_short_version = tester.raw_data.get("latestInstalledShortVersion")
        pretty_date = Time.at((latestInstalledDate / 1000)).strftime("%m/%d/%y %H:%M")
        puts "Installed version #{latest_installed_version} (#{latest_installed_short_version}) on #{pretty_date}".green
      end

      if tester.devices.length == 0
        puts "No devices".green
      else
        puts "#{tester.devices.length} devices:".green
        tester.devices.each do |device|
          puts "\u2022 #{device['model']}, #{device['osVersion']}".green
        end
      end
    end

    ##

    def add_external_tester(options)
      add_tester(options, true)
    end

    def add_internal_tester(options)
      add_tester(options, false)
    end

    def add_tester(options, external = true)
      @config = options

      tester_type = tester_type_str(external)

      login

      # tester = Spaceship::Tunes::Tester::External.new
      # Helper.log.debug "Tester: #{tester}".green

      begin
        tester = nil

        if external
          tester = Spaceship::Tunes::Tester::External.create!(email: config[:email],
                                                              first_name: config[:first_name],
                                                              last_name: config[:last_name],
                                                              group: config[:group_name])
        else
          tester = Spaceship::Tunes::Tester::External.create!(email: config[:email],
                                                              first_name: config[:first_name],
                                                              last_name: config[:last_name],
                                                              group: config[:group_name])
        end

        if config[:apple_id]
          puts "Adding #{tester_type} tester to app #{config[:apple_id]}".green
          tester.add_to_app!(config[:apple_id])
        end

        # puts "Tester: #{tester::email}"
        # puts "Tester: #{tester.first_name}"
        # puts "Tester: #{tester.last_name}"
        #
        # Spaceship::Tunes::Tester::all

        if tester
          email = tester.email
          puts "Invited #{tester_type} tester: #{email}".green
        end
      rescue => ex
        puts "Could not create #{tester_type} tester: #{ex}".red
        raise ex
      end
    end

    def add_tester_to_app(options)
      @config = options
      login

      email = config[:email]

      tester = Spaceship::Tunes::Tester::Internal.find(email)
      tester = Spaceship::Tunes::Tester::External.find(email) if tester.nil?

      if tester.nil?
        puts "Tester not found: #{email}".red
        return
      end

      the_app = app

      app_id = the_app.apple_id

      tester.add_to_app!(app_id)
      puts "Added #{tester.email} to #{app.name}".green
    end

    ##

    def find_tester_by_email(options, print_description = true)
      @config = options
      login

      email = config[:email]

      internal_tester = Spaceship::Tunes::Tester::Internal.find(email)
      if internal_tester
        puts "Found internal tester #{internal_tester.tester_id}".green
        describe_tester(internal_tester) if print_description
        return internal_tester
      else
        external_tester = Spaceship::Tunes::Tester::External.find(email)
        if external_tester
          puts "Found external tester #{internal_tester.tester_id}".green
          describe_tester(external_tester) if print_description
          return external_tester
        else
          puts "No tester found: #{email}".red
        end
      end
    end

    ##

    def remove_tester(options, external = true)
      tester_type = tester_type_str(external)

      @config = options
      login
      email = config[:email]

      tester = nil
      if external
        tester = Spaceship::Tunes::Tester::External.find(email)
      else
        tester = Spaceship::Tunes::Tester::Internal.find(email)
      end

      if tester
        tester.delete!
        puts "Removed #{tester_type} tester: #{tester.email}".green
      else
        puts "#{tester_type.capitalize} tester not found: #{email}".red
      end
    end

    def remove_internal_tester(options)
      remove_tester(options, false)
    end

    def remove_external_tester(options)
      remove_tester(options, true)
    end

    ##

    def reinvite_internal_tester(options)
      reinvite_tester(options, false)
    end

    def reinvite_external_tester(options)
      reinvite_tester(options, true)
    end

    def reinvite_tester(options, external = true)
      @config = options
      login

      tester_type = tester_type_str(external)
      email = config[:email]

      tester = nil
      if external
        tester = Spaceship::Tunes::Tester::External.find(email)
      else
        tester = Spaceship::Tunes::Tester::Internal.find(email)
      end

      if tester
        puts "Reinviting tester"

        options[:first_name] = tester.first_name
        options[:last_name] = tester.last_name

        tester.delete!

        new_tester = add_tester(options, external)

        describe_tester(new_tester)
      else
        puts "#{tester_type.capitalize} not found: #{email}".green
      end
    end
  end
end
