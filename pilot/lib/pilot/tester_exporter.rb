require 'spaceship/tunes/application'
require_relative 'module'
require_relative 'manager'

module Pilot
  class TesterExporter < Manager
    def export_testers(options)
      UI.user_error!("Export file path is required") unless options[:testers_file_path]

      start(options)
      require 'csv'

      app = find_app(apple_id: options[:apple_id], app_identifier: options[:app_identifier])
      if app
        testers = app.get_beta_testers(includes: "apps,betaTesterMetrics,betaGroups")
      else
        testers = Spaceship::ConnectAPI::BetaTester.all(includes: "apps,betaTesterMetrics,betaGroups")
      end

      file = config[:testers_file_path]

      CSV.open(file, "w") do |csv|
        csv << ['First', 'Last', 'Email', 'Groups', 'Installed Version', 'Install Date']

        testers.each do |tester|
          group_names = tester.beta_groups.map(&:name).join(";") || ""

          metric = (tester.beta_tester_metrics || []).first
          if metric.installed?
            install_version = "#{metric.installed_cf_bundle_short_version_string} (#{metric.installed_cf_bundle_version})"
            pretty_date = metric.installed_cf_bundle_version
          end

          csv << [tester.first_name, tester.last_name, tester.email, group_names, install_version, pretty_date]
        end

        UI.success("Successfully exported CSV to #{file}")
      end
    end

    def find_app(apple_id: nil, app_identifier: nil)
      if app_identifier
        app = Spaceship::ConnectAPI::App.find(app_identifier)
        UI.user_error!("Could not find an app by #{app_identifier}") unless app
        return app
      end

      if apple_id
        app = Spaceship::ConnectAPI::App.get(app_id: apple_id)
        UI.user_error!("Could not find an app by #{apple_id}") unless app
        return app
      end

      UI.user_error!("You must include an `app_identifier` to `list_testers`")
    end
  end
end
