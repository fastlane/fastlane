require "fastlane_core"
require "pilot/tester_util"

module Pilot
  class TesterManager < Manager
    def add_tester(options)
      start(options)

      begin
        tester = Spaceship::Tunes::Tester::Internal.find(config[:email])
        tester ||= Spaceship::Tunes::Tester::External.find(config[:email])

        if tester
          UI.success("Existing tester #{tester.email}")
        else
          tester = Spaceship::Tunes::Tester::External.create!(email: config[:email],
                                                              first_name: config[:first_name],
                                                              last_name: config[:last_name])
          UI.success("Successfully invited tester: #{tester.email}")
        end

        app_filter = (config[:apple_id] || config[:app_identifier])
        if app_filter
          begin
            app = Spaceship::Application.find(app_filter)
            UI.user_error!("Couldn't find app with '#{app_filter}'") unless app
            tester.add_to_app!(app.apple_id)
            UI.success("Successfully added tester to app #{app_filter}")
          rescue => ex
            UI.error("Could not add #{tester.email} to app: #{ex}")
            raise ex
          end
        end
      rescue => ex
        UI.error("Could not create tester #{config[:email]}")
        raise ex
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
      tester ||= Spaceship::Tunes::Tester::Internal.find(config[:email])

      if tester
        app_filter = (config[:apple_id] || config[:app_identifier])
        if app_filter
          begin
            app = Spaceship::Application.find(app_filter)
            UI.user_error!("Couldn't find app with '#{app_filter}'") unless app
            tester.remove_from_app!(app.apple_id)
            UI.success("Successfully removed tester #{tester.email} from app #{app_filter}")
          rescue => ex
            UI.error("Could not remove #{tester.email} from app: #{ex}")
            raise ex
          end
        else
          tester.delete!
          UI.success("Successfully removed tester #{tester.email}")
        end
      else
        UI.error("Tester not found: #{config[:email]}")
      end
    end

    def list_testers(options)
      start(options)
      require 'terminal-table'

      app_filter = (config[:apple_id] || config[:app_identifier])
      if app_filter
        app = Spaceship::Application.find(app_filter)
        UI.user_error!("Couldn't find app with '#{app_filter}'") unless app
        int_testers = Spaceship::Tunes::Tester::Internal.all_by_app(app.apple_id)
        ext_testers = Spaceship::Tunes::Tester::External.all_by_app(app.apple_id)
      else
        int_testers = Spaceship::Tunes::Tester::Internal.all
        ext_testers = Spaceship::Tunes::Tester::External.all
      end

      list(int_testers, "Internal Testers")
      puts "" # new line
      list(ext_testers, "External Testers")
    end

    private

    def list(all_testers, title)
      rows = []
      all_testers.each do |tester|
        rows << [tester.first_name, tester.last_name, tester.email, tester.devices.count, tester.full_version, tester.pretty_install_date]
      end

      puts Terminal::Table.new(
        title: title.green,
        headings: ["First", "Last", "Email", "Devices", "Latest Version", "Latest Install Date"],
        rows: rows
      )
    end

    # Print out all the details of a specific tester
    def describe_tester(tester)
      return unless tester

      rows = []

      rows << ["First name", tester.first_name]
      rows << ["Last name", tester.last_name]
      rows << ["Email", tester.email]

      groups = tester.raw_data.get("groups")

      if groups && groups.length > 0
        group_names = groups.map { |group| group["name"]["value"] }
        rows << ["Groups", group_names.join(', ')]
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
        rows: rows
      )
    end
  end
end
