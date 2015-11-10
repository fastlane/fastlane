module Fastfix
  class TablePrinter
    def self.print_summary(params, uuid)
      require 'terminal-table'
      rows = []

      rows << ["App Identifier", params[:app_identifier]]
      rows << ["Type", params[:type]]
      rows << ["UUID", uuid]
      rows << ["Environment Variable", Utils.environment_variable_name(params)]

      params = {}
      params[:rows] = rows
      params[:title] = "Installed Provisioning Profile".green

      puts ""
      puts Terminal::Table.new(params)
      puts ""
    end
  end
end
