module Match
  class TablePrinter
    def self.print_summary(params, uuid)
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

    # logs public key's  name, user, organisation, country, availability dates
    def self.print_certificate_info(params, cert_info)
      if cert_info.length > 0
        main_data = [
          ['App Identifier', params[:app_identifier]],
          ['Type', params[:type]],
          ['Environment Variable', Utils.environment_variable_name_cert(params)]
        ]

        params = {
            rows: (main_data + cert_info),
            title: "Installed Code Certificate".green
        }

        puts ""
        puts Terminal::Table.new(params)
        puts ""
      end
    rescue => ex
      UI.error(ex)
    end
  end
end
