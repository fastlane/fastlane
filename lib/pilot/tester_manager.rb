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
          Helper.log.info "Existing tester #{tester.email}".green
        else
          tester = Spaceship::Tunes::Tester::External.create!(email: config[:email],
                                                              first_name: config[:first_name],
                                                              last_name: config[:last_name])
          Helper.log.info "Successfully invited tester: #{tester.email}".green
        end

        app_filter = (config[:apple_id] || config[:app_identifier])
        if app_filter
          begin
            app = Spaceship::Application.find(app_filter)
            raise "Couldn't find app with '#{app_filter}'" unless app
            tester.add_to_app!(app.apple_id)
            Helper.log.info "Successfully added tester to app #{app_filter}".green
          rescue => ex
            Helper.log.error "Could not add #{tester.email} to app: #{ex}".red
            raise ex
          end
        end
      rescue => ex
        Helper.log.error "Could not create tester #{config[:email]}".red
        raise ex
      end
    end

    def find_tester(options)
      start(options)

      tester = Spaceship::Tunes::Tester::Internal.find(config[:email])
      tester ||= Spaceship::Tunes::Tester::External.find(config[:email])

      raise "Tester #{config[:email]} not found".red unless tester

      describe_tester(tester)
      return tester
    end

    def remove_tester(options)
      start(options)

      tester = Spaceship::Tunes::Tester::External.find(config[:email])
      tester ||= Spaceship::Tunes::Tester::Internal.find(config[:email])

      if tester
        tester.delete!
        Helper.log.info "Successfully removed tester #{tester.email}".green
      else
        Helper.log.error "Tester not found: #{config[:email]}".red
      end
    end

    def list_testers(options)
      start(options)
      require 'terminal-table'

      list(Spaceship::Tunes::Tester::Internal.all, "Internal Testers")
      puts "" # new line
      list(Spaceship::Tunes::Tester::External.all, "External Testers")
    end

    private

    def list(all_testers, title)
      rows = []
      all_testers.each do |tester|
        rows << [tester.first_name, tester.last_name, tester.email, tester.devices.count]
      end

      puts Terminal::Table.new(
        title: title.green,
        headings: ["First", "Last", "Email", "Devices"],
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
