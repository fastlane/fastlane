require "fastlane_core"

module Pilot
  class TesterExporter < Manager
    def export_testers(options)
      raise "Export file path is required".red unless options[:testers_file_path]

      start(options)
      require 'csv'

      testers = Spaceship::Tunes::Tester::External.all

      file = config[:testers_file_path]

      CSV.open(file, "w") do |csv|
        csv << ['First', 'Last', 'Email', 'Devices', 'Groups', 'Installed Version', 'Install Date']

        testers.each do |tester|
          groups = tester.raw_data.get("groups")

          group_names = ""
          if groups && groups.length > 0
            names = groups.map { |group| group["name"]["value"] }
            group_names = names.join(';')
          end

          install_version = ""
          install_date = ""

          latest_installed_date = tester.latest_install_date
          if latest_installed_date
            install_date = Time.at((latest_installed_date / 1000)).strftime("%m/%d/%y %H:%M")

            latest_installed_version = tester.latest_installed_version_number
            latest_installed_short_version = tester.latest_installed_build_number
            install_version = "#{latest_installed_version} (#{latest_installed_short_version})"
          end

          csv << [tester.first_name, tester.last_name, tester.email, tester.devices.count, group_names, install_version, install_date]
        end

        Helper.log.info "Successfully exported CSV to #{file}".green
      end
    end
  end
end
