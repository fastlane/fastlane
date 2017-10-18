require "fastlane_core"
require "pilot/tester_util"
require 'terminal-table'

module Pilot
  class TesterManager < Manager
    def add_tester(options)
      start(options)
      app = find_app(app_filter: config[:apple_id] || config[:app_identifier])
      UI.user_error!("You must provide either a Apple ID for the app (with the `:apple_id` option) or app identifier (with the `:app_identifier` option)") unless app

      tester = find_app_tester(email: config[:email], app: app)
      tester ||= create_tester(
        email: config[:email],
        first_name: config[:first_name],
        last_name: config[:last_name],
        app: app
      )
      begin
        groups = Spaceship::TestFlight::Group.add_tester_to_groups!(tester: tester, app: app, groups: config[:groups])
        if tester.kind_of?(Spaceship::Tunes::Tester::Internal)
          UI.success("Successfully added tester to app #{app.name}")
        else
          # tester was added to the group(s) in the above add_tester_to_groups() call, now we need to let the user know which group(s)
          if config[:groups]
            group_names = groups.map(&:name).join(", ")
            UI.success("Successfully added tester to group(s): #{group_names} in app: #{app.name}")
          else
            UI.success("Successfully added tester to the default tester group in app: #{app.name}")
          end
        end
      rescue => ex
        UI.error("Could not add #{tester.email} to app: #{app.name}")
        raise ex
      end
    end

    def find_tester(options)
      start(options)

      app_filter = (config[:apple_id] || config[:app_identifier])
      app = find_app(app_filter: app_filter)

      tester = find_app_tester(email: config[:email], app: app)
      UI.user_error!("Tester #{config[:email]} not found") unless tester

      describe_tester(tester)
      return tester
    end

    def remove_tester(options)
      start(options)

      app_filter = (config[:apple_id] || config[:app_identifier])
      app = find_app(app_filter: app_filter)

      tester = find_app_tester(email: config[:email], app: app)
      UI.user_error!("Tester #{config[:email]} not found") unless tester

      unless app
        tester.delete!
        UI.success("Successfully removed tester #{tester.email} from Users and Roles")
        return
      end

      begin
        # If no groups are passed to options, remove the tester from the app-level,
        # otherwise remove the tester from the groups specified.
        if config[:groups].nil? && tester.kind_of?(Spaceship::Tunes::Tester::External)
          test_flight_testers = Spaceship::TestFlight::Tester.search(app_id: app.apple_id, text: tester.email, is_email_exact_match: true)

          if test_flight_testers.length > 1
            UI.user_error!("Could not remove #{tester.email} from app: #{app.name}, reason: too many matches: #{test_flight_testers}")
          elsif test_flight_testers.length == 0
            UI.user_error!("Could not remove #{tester.email} from app: #{app.name}, reason: unable to find tester on app")
          end
          test_flight_tester = test_flight_testers.first
          test_flight_tester.remove_from_app!(app_id: app.apple_id)
          UI.success("Successfully removed tester, #{test_flight_tester.email}, from app: #{app.name}")
        else
          groups = Spaceship::TestFlight::Group.remove_tester_from_groups!(tester: tester, app: app, groups: config[:groups])
          group_names = groups.map(&:name).join(", ")
          UI.success("Successfully removed tester #{tester.email} from app #{app.name} in group(s) #{group_names}")
        end
      rescue => ex
        UI.error("Could not remove #{tester.email} from app: #{ex}")
        raise ex
      end
    end

    def list_testers(options)
      start(options)

      app_filter = (config[:apple_id] || config[:app_identifier])
      if app_filter
        list_testers_by_app(app_filter)
      else
        list_testers_global
      end
    end

    private

    def find_app(app_filter: nil)
      if app_filter
        app = Spaceship::Application.find(app_filter)
        UI.user_error!("Could not find an app by #{app_filter}") unless app
        return app
      end
      nil
    end

    def find_app_tester(email: nil, app: nil)
      current_user = find_current_user

      if current_user.admin?
        tester = Spaceship::Tunes::Tester::Internal.find(email)
        tester ||= Spaceship::Tunes::Tester::External.find(email)
      elsif current_user.app_manager?
        unless app
          UI.user_error!("Account #{current_user.email_address} is only an 'App Manager' and therefore you must also define what app this tester (#{email}) should be added to")
        end
        tester = Spaceship::Tunes::Tester::Internal.find_by_app(app.apple_id, email)
        tester ||= Spaceship::Tunes::Tester::External.find_by_app(app.apple_id, email)
      else
        UI.user_error!("Account #{current_user.email_address} doesn't have a role that is allowed to administer app testers, current roles: #{current_user.roles}")
        tester = nil
      end

      if tester
        UI.success("Found existing tester #{email}")
      end

      return tester
    end

    def find_current_user
      current_user_email = Spaceship::Tunes.client.user_email
      current_user_apple_id = Spaceship::Tunes.client.user

      current_user = Spaceship::Members.find(current_user_email)
      unless current_user
        UI.user_error!("Unable to find a member for AppleID: #{current_user_apple_id}, email: #{current_user_email}")
      end
      return current_user
    end

    def create_tester(email: nil, first_name: nil, last_name: nil, app: nil)
      current_user = find_current_user
      if current_user.admin?
        tester = Spaceship::Tunes::Tester::External.create!(email: email,
                                                       first_name: first_name,
                                                        last_name: last_name)
        UI.success("Successfully added tester: #{email} to your account")
      elsif current_user.app_manager?

        Spaceship::TestFlight::Tester.create_app_level_tester(app_id: app.apple_id,
                                                          first_name: first_name,
                                                           last_name: last_name,
                                                               email: email)
        tester = Spaceship::Tunes::Tester::External.find_by_app(app.apple_id, email)
        UI.success("Successfully added tester: #{email} to app: #{app.name}")
      else
        UI.user_error!("Current account doesn't have permission to create a tester")
      end

      return tester
    rescue => ex
      UI.error("Could not create tester #{email}")
      raise ex
    end

    def list_testers_by_app(app_filter)
      app = Spaceship::Application.find(app_filter)
      UI.user_error!("Couldn't find app with '#{app_filter}'") unless app

      int_testers = Spaceship::Tunes::Tester::Internal.all_by_app(app.apple_id)
      ext_testers = Spaceship::Tunes::Tester::External.all_by_app(app.apple_id)

      list_by_app(int_testers, "Internal Testers")
      puts ""
      list_by_app(ext_testers, "External Testers")
    end

    def list_testers_global
      begin
        int_testers = Spaceship::Tunes::Tester::Internal.all
        ext_testers = Spaceship::Tunes::Tester::External.all
      rescue Spaceship::Client::InsufficientPermissions
        UI.user_error!("You don't have the permission to list the testers of your whole team. Please provide an app identifier to list all testers of a specific application.")
      end

      list_global(int_testers, "Internal Testers")
      puts ""
      list_global(ext_testers, "External Testers")
    end

    def list_global(all_testers, title)
      headers = ["First", "Last", "Email", "Groups", "Devices", "Latest Version", "Latest Install Date"]
      list(all_testers, "#{title} (#{all_testers.count})", headers) do |tester|
        [
          tester.first_name,
          tester.last_name,
          tester.email,
          tester.groups_list,
          tester.devices.count,
          tester.latest_build,
          tester.pretty_install_date
        ]
      end
    end

    def list_by_app(all_testers, title)
      headers = ["First", "Last", "Email", "Groups"]
      list(all_testers, "#{title} (#{all_testers.count})", headers) do |tester|
        [
          tester.first_name,
          tester.last_name,
          tester.email,
          tester.groups_list
          # Testers returned by the query made in the context of an app do not contain
          # the devices, version, or install date information
        ]
      end
    end

    # Requires a block that accepts a tester and returns an array of tester column values
    def list(all_testers, title, headings)
      rows = all_testers.map { |tester| yield tester }
      puts Terminal::Table.new(
        title: title.green,
        headings: headings,
        rows: FastlaneCore::PrintTable.transform_output(rows)
      )
    end

    # Print out all the details of a specific tester
    def describe_tester(tester)
      return unless tester

      rows = []

      rows << ["First name", tester.first_name]
      rows << ["Last name", tester.last_name]
      rows << ["Email", tester.email]

      if tester.groups.to_s.length > 0
        rows << ["Groups", tester.groups_list]
      end

      if tester.latest_install_date
        rows << ["Latest Version", tester.latest_build]
        rows << ["Latest Install Date", tester.pretty_install_date]
      end

      if tester.devices.to_s.length == 0
        rows << ["Devices", "No devices"]
      else
        rows << ["#{tester.devices.count} Devices", ""]
        tester.devices.each do |device|
          current = "\u2022 #{device['model']}, iOS #{device['osVersion']}"

          if rows.last[1].length == 0
            rows.last[1] = current
          else
            rows << ["", current]
          end
        end
      end

      puts Terminal::Table.new(
        title: tester.email.green,
        rows: FastlaneCore::PrintTable.transform_output(rows)
      )
    end
  end
end
