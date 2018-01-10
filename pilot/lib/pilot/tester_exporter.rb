require 'spaceship/tunes/application'
require 'spaceship/test_flight/tester'
require_relative 'tester_util'
require_relative 'module'
require_relative 'manager'

module Pilot
  class TesterExporter < Manager
    def export_testers(options)
      UI.user_error!("Export file path is required") unless options[:testers_file_path]

      start(options)
      require 'csv'

      app_filter = (config[:apple_id] || config[:app_identifier])
      if app_filter
        app = Spaceship::Tunes::Application.find(app_filter)

        testers = Spaceship::TestFlight::Tester.all(app_id: app.apple_id)
      else
        testers = Spaceship::TestFlight::Tester.all
      end

      file = config[:testers_file_path]

      CSV.open(file, "w") do |csv|
        csv << ['First', 'Last', 'Email', 'Groups', 'Installed Version', 'Install Date']

        testers.each do |tester|
          group_names = tester.groups.join(";") || ""
          latest_install_info = tester.latest_install_info
          install_version = latest_install_info["latestInstalledShortVersion"] || ""
          pretty_date = tester.pretty_install_date || ""

          csv << [tester.first_name, tester.last_name, tester.email, group_names, install_version, pretty_date]
        end

        UI.success("Successfully exported CSV to #{file}")
      end
    end
  end
end
