require "fastlane_core"
require "pilot/tester_util"

module Pilot
  class TesterExporter < Manager
    def export_testers(options)
      raise "Export file path is required".red unless options[:testers_file_path]

      start(options)
      require 'csv'

      app_filter = (config[:apple_id] || config[:app_identifier])
      if app_filter
        app = Spaceship::Application.find(app_filter)
        testers = Spaceship::Tunes::Tester::External.all_by_app(app.apple_id)
      else
        testers = Spaceship::Tunes::Tester::External.all
      end

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

          install_version = tester.full_version || ""
          pretty_date = tester.pretty_install_date || ""

          csv << [tester.first_name, tester.last_name, tester.email, tester.devices.count, group_names, install_version, pretty_date]
        end

        Helper.log.info "Successfully exported CSV to #{file}".green
      end
    end
  end
end
