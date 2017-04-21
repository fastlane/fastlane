require "fastlane_core"
require "pilot/tester_util"
require 'terminal-table'

module Pilot
  class TesterManager < Manager
    def add_tester(options)
      start(options)

      begin
        tester = Spaceship::Tunes::Tester::External.find(config[:email])
        if tester
          UI.success("Existing tester #{tester.email}")
        else
          # make sure the user isn't already an internal tester, because we don't support those
          internal_tester = Spaceship::Tunes::Tester::Internal.find(config[:email])
          UI.user_error!("#{internal_tester.email} is an internal tester; pilot does not support internal testers") unless internal_tester.nil?

          tester = Spaceship::Tunes::Tester::External.create!(email: config[:email],
                                                              first_name: config[:first_name],
                                                              last_name: config[:last_name])
          UI.success("Successfully added tester: #{tester.email} to your account")
        end
      rescue => ex
        UI.error("Could not create tester #{config[:email]}")
        raise ex
      end

      app_filter = (config[:apple_id] || config[:app_identifier])
      if app_filter
        begin
          app = Spaceship::Application.find(app_filter)
          UI.user_error!("Couldn't find app with '#{app_filter}'") unless app

          groups = add_tester_to_groups!(tester: tester, app: app, groups: config[:groups])
          group_names = groups.map(&:name).join(", ")
          UI.success("Successfully added tester to app #{app_filter} in group(s) #{group_names}")
        rescue => ex
          UI.error("Could not add #{tester.email} to app: #{app.name}")
          raise ex
        end
      end
    end

    def find_tester(options)
      start(options)

      tester = Spaceship::Tunes::Tester::Internal.find(config[:email])
      tester ||= Spaceship::Tunes::Tester::External.find(config[:email])

      UI.user_error!("Tester #{config[:email]} not found") unless tester

      describe_tester(tester)
      return tester
    end

    def remove_tester(options)
      start(options)

      tester = Spaceship::Tunes::Tester::External.find(config[:email])

      if tester
        app_filter = (config[:apple_id] || config[:app_identifier])
        if app_filter
          begin
            app = Spaceship::Application.find(app_filter)
            UI.user_error!("Couldn't find app with '#{app_filter}'") unless app
            groups = remove_tester_from_groups!(tester: tester, app: app, groups: config[:groups])
            group_names = groups.map(&:name).join(", ")
            UI.success("Successfully removed tester #{tester.email} from app #{app_filter} in group(s) #{group_names}")
          rescue => ex
            UI.error("Could not remove #{tester.email} from app: #{ex}")
            raise ex
          end
        else
          tester.delete!
          UI.success("Successfully removed tester #{tester.email}")
        end
      else
        internal_tester = Spaceship::Tunes::Tester::Internal.find(config[:email])
        UI.user_error!("#{internal_tester.email} is an internal tester; pilot does not support internal testers") unless internal_tester.nil?

        UI.user_error!("Tester not found: #{config[:email]}")
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

    def perform_for_groups_in_app(app: nil, groups: nil, &block)
      if groups.nil?
        default_external_group = app.default_external_group
        if default_external_group.nil?
          UI.user_error!("The app #{app.name} does not have a default external group. Please make sure to pass group names to the `:groups` option.")
        end
        test_flight_groups = [default_external_group]
      else
        test_flight_groups = Spaceship::TestFlight::Group.filter_groups(app_id: app.apple_id) do |group|
          groups.include?(group.name)
        end

        UI.user_error!("There are no groups available matching the names passed to the `:groups` option.") if test_flight_groups.empty?
      end

      test_flight_groups.each(&block)
    end

    def add_tester_to_groups!(tester: nil, app: nil, groups: nil)
      perform_for_groups_in_app(app: app, groups: groups) { |group| group.add_tester!(tester) }
    end

    def remove_tester_from_groups!(tester: nil, app: nil, groups: nil)
      perform_for_groups_in_app(app: app, groups: groups) { |group| group.remove_tester!(tester) }
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
      list(all_testers, title, headers) do |tester|
        [
          tester.first_name,
          tester.last_name,
          tester.email,
          tester.groups_list,
          tester.devices.count,
          tester.full_version,
          tester.pretty_install_date
        ]
      end
    end

    def list_by_app(all_testers, title)
      headers = ["First", "Last", "Email", "Groups"]
      list(all_testers, title, headers) do |tester|
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

      if tester.groups.length > 0
        rows << ["Groups", tester.groups_list]
      end

      if tester.latest_install_date
        rows << ["Latest Version", tester.full_version]
        rows << ["Latest Install Date", tester.pretty_install_date]
      end

      if tester.devices.length == 0
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
