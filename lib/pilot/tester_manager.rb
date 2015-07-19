require "fastlane_core"

module Pilot
  class TesterManager < Manager
    def add_tester(options, external = true)
      self.run(options)
      tester_type = tester_type_str(external)

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
          Helper.log.info "Adding #{tester_type} tester to app #{config[:apple_id]}".green
          tester.add_to_app!(config[:apple_id])
        end

        if tester
          Helper.log.info "Invited #{tester_type} tester: #{tester.email}".green
        end
      rescue => ex
        Helper.log.error "Could not create #{tester_type} tester: #{ex}".red
        raise ex
      end
    end

    def add_tester_to_app(options)
      self.run(options)

      tester = Spaceship::Tunes::Tester::Internal.find(config[:email])
      tester = Spaceship::Tunes::Tester::External.find(config[:email]) unless tester

      unless tester
        Helper.log.error "Tester not found: #{config[:email]}".red
        return
      end

      tester.add_to_app!(app.apple_id)
      Helper.log.info "Added #{tester.email} to #{app.name}".green
    end

    def find_tester_by_email(options)
      self.run(options)

      internal_tester = Spaceship::Tunes::Tester::Internal.find(config[:email])
      if internal_tester
        Helper.log.info "Found internal tester #{internal_tester.tester_id}".green
        describe_tester(internal_tester)
        return internal_tester
      else
        external_tester = Spaceship::Tunes::Tester::External.find(config[:email])
        if external_tester
          Helper.log.info "Found external tester #{internal_tester.tester_id}".green
          describe_tester(external_tester)
          return external_tester
        else
          Helper.log.error "No tester found: #{config[:email]}".red
        end
      end
    end

    def remove_tester(options, external = true)
      self.run(options)

      tester_type = tester_type_str(external)

      email = config[:email]

      tester = nil
      if external
        tester = Spaceship::Tunes::Tester::External.find(email)
      else
        tester = Spaceship::Tunes::Tester::Internal.find(email)
      end

      if tester
        tester.delete!
        Helper.log.info "Removed #{tester_type} tester: #{tester.email}".green
      else
        Helper.log.error "#{tester_type.capitalize} tester not found: #{email}".red
      end
    end

    def reinvite_tester(options)
      self.run(options)

      tester_type = tester_type_str(external)

      tester = Spaceship::Tunes::Tester::External.find(config[:email])

      if tester
        Helper.log.info "Sending another invite to #{config[:email]}"

        options[:first_name] = tester.first_name
        options[:last_name] = tester.last_name

        tester.delete!

        new_tester = add_tester(options, external)

        describe_tester(new_tester)
      else
        Helper.log.error "#{tester_type.capitalize} not found: #{config[:email]}".green
      end
    end

    private
      def tester_type_str(external)
        external ? "external" : "internal"
      end

      def describe_tester(tester)
        return unless tester
        require 'terminal-table'

        rows = []

        rows << ["First name", tester.first_name]
        rows << ["Last name", tester.last_name]
        rows << ["Email", tester.email]

        groups = tester.raw_data.get("groups")

        if groups && groups.length > 0
          group_names = groups.map { |group| group["name"]["value"] }
          rows << ["Groups", group_names.join(', ')]
        end

        latestInstalledDate = tester.raw_data.get("latestInstalledDate")
        if latestInstalledDate
          latest_installed_version = tester.raw_data.get("latestInstalledVersion")
          latest_installed_short_version = tester.raw_data.get("latestInstalledShortVersion")
          pretty_date = Time.at((latestInstalledDate / 1000)).strftime("%m/%d/%y %H:%M")

          rows << ["Latest Version", "#{latest_installed_version} (#{latest_installed_short_version})"]
          rows << ["Latest Install Date", pretty_date]
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

        table = Terminal::Table.new(
          title: tester.email.green,
          # headings: ['Action', 'Description', 'Author'],
          rows: rows
        )
        puts table
      end
  end
end
