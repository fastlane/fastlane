require_relative 'module'
require_relative 'manager'
require_relative 'tester_manager'

module Pilot
  class TesterImporter < Manager
    def import_testers(options)
      UI.user_error!("Import file path is required") unless options[:testers_file_path]

      start(options)

      require 'csv'

      file = config[:testers_file_path]
      tester_manager = Pilot::TesterManager.new
      imported_tester_count = 0

      groups = options[:groups]

      CSV.foreach(file, "r") do |row|
        first_name, last_name, email, testing_groups = row

        unless email
          UI.error("No email found in row: #{row}")
          next
        end

        unless email.index("@")
          UI.error("No email found in row: #{row}")
          next
        end

        # Add this the existing config hash to pass it to the TesterManager
        config[:first_name] = first_name
        config[:last_name] = last_name
        config[:email] = email
        config[:groups] = groups
        if testing_groups
          config[:groups] = testing_groups.split(";")
        end

        begin
          tester_manager.add_tester(config)
          imported_tester_count += 1
        rescue
          # do nothing, move on to the next row
        end
      end

      UI.success("Successfully imported #{imported_tester_count} testers from #{file}")
    end
  end
end
