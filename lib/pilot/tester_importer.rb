require "fastlane_core"

module Pilot
  class TesterImporter < Manager
    def import_testers(options)
      raise "Import file path is required".red unless options[:testers_file_path]

      self.run(options)

      require 'csv'

      file = config[:testers_file_path]
      tester_manager = Pilot::TesterManager.new
      imported_tester_count = 0

      CSV.foreach(file, "r") do |row|

        begin
          first_name = row[0]
          last_name = row[1]
          email = row[2]
        rescue => ex
          Helper.log.error "Invalid format for row: #{row}".red
        end

        if email.nil?
          Helper.log.error "No email in row: #{row}".red
          next
        end

        config[:first_name] = first_name
        config[:last_name] = last_name
        config[:email] = email

        begin
          tester_manager.add_tester(config)
          imported_tester_count += 1
        rescue => ex
          # do nothing, move on to the next row
        end

      end

      Helper.log.info "Imported #{imported_tester_count} testers from #{file}".green

    end
  end
end
