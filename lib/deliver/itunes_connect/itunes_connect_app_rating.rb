require 'json'

module Deliver
  class ItunesConnect < FastlaneCore::ItunesConnect
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

      if rows.count != (config.count - 1) # -1 the kids
        raise "The number of options passed in the config file does not match the number of options available on iTC! Make sure to use the latest template from https://github.com/KrauseFx/deliver/blob/master/assets/example_rating_config.json".red
      end


      # Setting all the values based on config file
      rows.each_with_index do |row, index|
        current = config[index]

        level = name_for_level(current['level'], current['type'] == 'boolean')

        Helper.log.info "Setting '#{current['comment']}' to #{level}.".green

        radio_value = "ITC.apps.ratings.level.#{level}"

        row.first("td > div[radio-value='#{radio_value}']").click
      end


      # Apple, doing some extra thingy for the kids section
      begin
        val = config.last['level'].to_i
        currently_enabled = (all("div[itc-checkbox='tempPageContent.ratingDialog.madeForKidsChecked'] > * > input").last.value != "")
        Helper.log.info "Setting kids mode to #{val}".green
        if val > 0
          if not currently_enabled
            all("div[itc-checkbox='tempPageContent.ratingDialog.madeForKidsChecked'] > * > a").last.click
          end

          # Kids is enabled, check mode
          first("select[ng-model='tempRatings.ageBand'] > option[value='#{val - 1}']").select_option # -1 since 0 is no kids mode
        else
          if currently_enabled
            # disable kids mode
            all("div[itc-checkbox='tempPageContent.ratingDialog.madeForKidsChecked'] > * > a").last.click
          end
        end
      rescue 
        Helper.log.warn "Couldn't set kids mode because of other options."
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