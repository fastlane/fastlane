module Deliver
  class AppMetadata
    #####################################################
    # @!group Screenshot related
    #####################################################

    # Removes all currently enabled screenshots for the given language.
    # @param (String) language The language, which has to be in this list: {FastlaneCore::Languages}.
    def clear_all_screenshots(language)
      raise AppMetadataParameterError.new(INVALID_LANGUAGE_ERROR) unless FastlaneCore::Languages::ALL_LANGUAGES.include?language

      update_localized_value('software_screenshots', {language => {}}) do |field, useless, language|
        field.children.remove # remove all the screenshots
      end
      information[language][:screenshots] = []
      true
    end

    # Appends another screenshot to the already existing ones
    # @param (String) language The language, which has to be in this list: {FastlaneCore::Languages}.
    # @param (Deliver::AppScreenshot) app_screenshot The screenshot you want to add to the app metadata.
    # @raise (AppMetadataTooManyScreenshotsError) When there are already 5 screenshots (MAXIMUM_NUMBER_OF_SCREENSHOTS).

    def add_screenshot(language, app_screenshot)
      raise AppMetadataParameterError.new(INVALID_LANGUAGE_ERROR) unless FastlaneCore::Languages::ALL_LANGUAGES.include?language

      create_locale_if_not_exists(language)

      # Fetch the 'software_screenshots' node (array) for the specific locale
      locales = self.fetch_value("//x:locale[@name='#{language}']")

      screenshots = self.fetch_value("//x:locale[@name='#{language}']/x:software_screenshots").first

      if not screenshots or screenshots.children.count == 0
        screenshots.remove if screenshots

        # First screenshot ever
        screenshots = Nokogiri::XML::Node.new('software_screenshots', @data)
        locales.first << screenshots

        node_set = Nokogiri::XML::NodeSet.new(@data)
        node_set << app_screenshot.create_xml_node(@data, 1)
        screenshots.children = node_set
      else
        # There is already at least one screenshot
        next_index = 1
        screenshots.children.each do |screen|
          if screen['display_target'] == app_screenshot.screen_size
            next_index += 1
          end
        end

        if next_index > MAXIMUM_NUMBER_OF_SCREENSHOTS
          raise AppMetadataTooManyScreenshotsError.new("Only #{MAXIMUM_NUMBER_OF_SCREENSHOTS} screenshots are allowed per language per device type (#{app_screenshot.screen_size})")
        end

        # Ready for storing the screenshot into the metadata.xml now
        screenshots.children.after(app_screenshot.create_xml_node(@data, next_index))
      end

      information[language][:screenshots] << app_screenshot

      app_screenshot.store_file_inside_package(@package_path)
    end

    # This method will clear all screenshots and set the new ones you pass
    # @param new_screenshots
    #   +code+
    #    {
    #     'de-DE' => [
    #       AppScreenshot.new('path/screenshot1.png', Deliver::ScreenSize::IOS_35),
    #       AppScreenshot.new('path/screenshot2.png', Deliver::ScreenSize::IOS_40),
    #       AppScreenshot.new('path/screenshot3.png', Deliver::ScreenSize::IOS_IPAD)
    #     ]
    #    }
    # This method uses {#clear_all_screenshots} and {#add_screenshot} under the hood.
    # @return [bool] true if everything was successful
    # @raise [AppMetadataParameterError] error is raised when parameters are invalid
    def set_all_screenshots(new_screenshots)
      error_text = "Please pass a hash, containing an array of AppScreenshot objects"
      raise AppMetadataParameterError.new(error_text) unless new_screenshots.kind_of?Hash

      new_screenshots.each do |key, value|
        if key.kind_of?String and value.kind_of?Array and value.count > 0 and value.first.kind_of?AppScreenshot

          self.clear_all_screenshots(key)

          value.each do |screen|
            add_screenshot(key, screen)
          end
        else
          raise AppMetadataParameterError.new(error_text)
        end
      end
      true
    end

    # Automatically add all screenshots contained in the given directory to the app.
    #
    # This method will automatically detect which device type each screenshot is.
    #
    # This will also clear all existing screenshots before setting the new ones.
    # @param (Hash) hash A hash containing a different path for each locale ({FastlaneCore::Languages::ALL_LANGUAGES})
    # @param (Bool) Use the framed screenshots? Only use it if you use frameit 2.0

    def set_screenshots_for_each_language(hash, use_framed = false)
      raise AppMetadataParameterError.new("Parameter needs to be an hash, containg strings with the new description") unless hash.kind_of?Hash
      hash.each do |language, current_path|
        resulting_path = "#{current_path}/**/*.{png,jpg,jpeg}"

        raise AppMetadataParameterError.new(INVALID_LANGUAGE_ERROR) unless FastlaneCore::Languages::ALL_LANGUAGES.include?language

        # https://stackoverflow.com/questions/21688855/
        # File::FNM_CASEFOLD = ignore case
        if Dir.glob(resulting_path, File::FNM_CASEFOLD).count == 0
          Helper.log.error("No screenshots found at the given path '#{resulting_path}'")
        else
          self.clear_all_screenshots(language)

          Dir.glob(resulting_path, File::FNM_CASEFOLD).sort.each do |path|
            # When frameit is enabled, we only want to upload the framed screenshots
            if use_framed
              # Except for Watch screenshots, they are okay without _framed
              is_apple_watch = ((AppScreenshot.new(path).screen_size == AppScreenshot::ScreenSize::IOS_APPLE_WATCH) rescue false)
              unless is_apple_watch
                next unless path.include?"_framed."
              end
            else
              next if path.include?"_framed."
            end

            begin
              add_screenshot(language, Deliver::AppScreenshot.new(path))
            rescue AppMetadataTooManyScreenshotsError => ex
              # We just use the first 5 ones
            end
          end
        end
      end

      true
    end

    # This method will run through all the available locales, check if there is
    # a folder for this language (e.g. 'en-US') and use all screenshots in there
    # @param (String) path A path to the folder, which contains a folder for each locale
    # @param (Bool) Use the framed screenshots? Only use it if you use frameit 2.0
    def set_all_screenshots_from_path(path, use_framed = false)
      raise AppMetadataParameterError.new("Parameter needs to be a path (string)") unless path.kind_of?String

      found = false
      FastlaneCore::Languages::ALL_LANGUAGES.each do |language|
        full_path = path + "/#{language}"
        if File.directory?(full_path)
          found = true
          set_screenshots_for_each_language({
            language => full_path
          }, use_framed)
        end
      end
      return found
    end
  end
end
