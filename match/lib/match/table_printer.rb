require 'terminal-table'

require 'fastlane_core/print_table'
require_relative 'module'
require_relative 'utils'

module Match
  class TablePrinter
    # logs public key's  name, user, organisation, country, availability dates
    def self.print_certificate_info(cert_info: nil)
      params = {
        rows: cert_info,
        title: "Installed Certificate".green
      }

      puts("")
      puts(Terminal::Table.new(params))
      puts("")
    rescue => ex
      UI.error(ex)
    end

    def self.print_summary(app_identifier: nil, type: nil, platform: :ios)
      rows = []

      type = type.to_sym

      rows << ["App Identifier", "", app_identifier]
      rows << ["Type", "", type]
      rows << ["Platform", "", platform.to_s]

      {
        Utils.environment_variable_name(app_identifier: app_identifier, type: type, platform: platform) => "Profile UUID",
        Utils.environment_variable_name_profile_name(app_identifier: app_identifier, type: type, platform: platform) => "Profile Name",
        Utils.environment_variable_name_profile_path(app_identifier: app_identifier, type: type, platform: platform) => "Profile Path",
        Utils.environment_variable_name_team_id(app_identifier: app_identifier, type: type, platform: platform) => "Development Team ID"
      }.each do |env_key, name|
        rows << [name, env_key, ENV[env_key]]
      end

      params = {}
      params[:rows] = FastlaneCore::PrintTable.transform_output(rows)
      params[:title] = "Installed Provisioning Profile".green
      params[:headings] = ['Parameter', 'Environment Variable', 'Value']

      puts("")
      puts(Terminal::Table.new(params))
      puts("")
    end
  end
end
