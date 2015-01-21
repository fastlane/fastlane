require 'json'

module Deliver  
  class ItunesConnect
    # Setting the app's age restrictions

    def set_app_rating!(app, path_to_json)
      path_to_json = File.expand_path(path_to_json)
      raise "Could not find app rating JSON file" unless File.exists?(path_to_json)

      config = JSON.parse(File.read(path_to_json))

      verify_app(app)
      open_app_page(app)

      Helper.log.info "Updating the app's rating".green

      first("a[ng-show='versionInfo.ratings.isEditable']").click # open the ratings screen

      rows = wait_for_elements(".defaultTable.ratingsTable > tbody > tr.ng-scope") # .ng-scope, since there is one empty row

      if rows.count != config.count
        raise "The number of options passed in the config file does not match the number of options available on iTC!".red
      end



      # Setting all the values based on config file
      rows.each_with_index do |row, index|
        current = config[index]

        level = name_for_level(current['level'], current['type'] == 'boolean')

        Helper.log.info "Setting '#{current['comment']}' to #{level}.".green

        radio_value = "ITC.apps.ratings.level.#{level}"

        row.first("td > div[radio-value='#{radio_value}']").click
      end

      # Check if there is a warning or error message because of this rating
      error_message = first("p[ng-show='tempPageContent.ratingDialog.showErrorMessage']")
      Helper.log.error error_message.text if error_message

      Helper.log.info "Finished setting updated app rating"
      
      (click_on "Done" rescue nil)

      (click_on "Save" rescue nil) # if nothing has changed, there is no back button and we don't care
    rescue => ex
      error_occured(ex)
    end

    private
      def name_for_level(level, is_boolean)
        if is_boolean
          return "NO" if level == 0
          return "YES" if level == 1
        else
          return "NONE" if level == 0
          return "INFREQUENT_MILD" if level == 1
          return "FREQUENT_INTENSE" if level == 2
        end

        raise "Unknown level '#{level}' - must be 0, 1 or 2".red
      end
  end
end