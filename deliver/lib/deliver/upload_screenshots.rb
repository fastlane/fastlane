require 'spaceship/tunes/tunes'

require_relative 'app_screenshot'
require_relative 'module'
require_relative 'loader'

module Deliver
  # upload screenshots to App Store Connect
  class UploadScreenshots
    def upload(options, screenshots)
      return if options[:skip_screenshots]
      return if options[:edit_live]

      require 'pp'

      legacy_app = options[:app]
      app_id = legacy_app.apple_id
      app = Spaceship::ConnectAPI::App.get(app_id: app_id)

      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])
      version = app.get_prepare_for_submission_app_store_version(platform: platform)
      UI.user_error!("Could not find a version to edit for app '#{app.name}' for '#{platform}'") unless version

      UI.message("Starting with the upload of screenshots...")
      screenshots_per_language = screenshots.group_by(&:language)
      
      
      # pp screenshots_per_language

      localizations = version.get_app_store_version_localizations

      # TODO: Delete existing screenshots for each language
      if options[:overwrite_screenshots]
        UI.message("Removing all previously uploaded screenshots...")

        # Get localizations on version
        localizations.each do |localization|
          # Only delete screenshots if trying to upload
          next unless screenshots_per_language.keys.include?(localization.locale)
          
          # Iterate over all screenshots for each set and delete
          screenshot_sets = localization.get_app_screenshot_sets
          screenshot_sets.each do |screenshot_set|
            screenshot_set.app_screenshots.each do |screenshot|
              UI.verbose("Deleting screenshot - #{localization.locale} #{screenshot_set.screenshot_display_type} #{screenshot.id}")
              screenshot.delete!
            end
          end
        end
      end

      # Finding languages to enable
      languages = screenshots_per_language.keys
      locales_to_enable = languages - localizations.map(&:locale)

      if locales_to_enable.count > 0
        lng_text = "language"
        lng_text += "s" if locales_to_enable.count != 1
        Helper.show_loading_indicator("Activating #{lng_text} #{locales_to_enable.join(', ')}...")

        locales_to_enable.each do |locale|
          version.create_app_store_version_localization(attributes: {
            locale: locale
          })
        end

        Helper.hide_loading_indicator

        # Refresh version localizations
        localizations = version.get_app_store_version_localizations
      end

      # Upload screenshots
      indized = {} # per language and device type

      screenshots_per_language.each do |language, screenshots_for_language|
        # Find localization to upload screenshots to
        localization = localizations.find do |localization|
          localization.locale == language
        end

        unless localization
          UI.error("Couldn't find localization on version for #{language}")
          next
        end

        indized[localization.locale] ||= {}

        # Create map to find screenshot set to add screenshot to
        app_screenshot_sets_map = {}
        app_screenshot_sets = localization.get_app_screenshot_sets
        app_screenshot_sets.each do |app_screenshot_set|
          app_screenshot_sets_map[app_screenshot_set.screenshot_display_type] = app_screenshot_set

          # Set initial screnshot count
          indized[localization.locale][app_screenshot_set.screenshot_display_type] ||= app_screenshot_set.app_screenshots.size
        end

        require 'pp'
        puts "INDIZED"
        pp indized

        UI.message("Uploading #{screenshots_for_language.length} screenshots for language #{language}")
        screenshots_for_language.each do |screenshot|

          display_type = screenshot.device_type
          set = app_screenshot_sets_map[display_type]

          if display_type.nil?
            UI.error("Error... Screenshot size #{screenshot.screen_size} not valid for App Store Connect")
            next
          end
          
          unless set
            set = localization.create_app_screenshot_set(attributes: {
              screenshotDisplayType: display_type
            })
            app_screenshot_sets_map[display_type] = set

            indized[localization.locale][set.screenshot_display_type] = 0
          end

          index = indized[localization.locale][set.screenshot_display_type]

          if index >= 10
            UI.error("Too many screenshots found for device '#{screenshot.formatted_name}' in '#{screenshot.language}', skipping this one (#{screenshot.path})")
            next
          end

          indized[localization.locale][set.screenshot_display_type] += 1
          
          # TODO: Do we need to do something specific for messages?
          # Also.. what is the messages type even for?
          UI.message("Uploading '#{screenshot.path}'...")
          set.upload_screenshot(path: screenshot.path)
        end

      end
      UI.success("Successfully uploaded screenshots to App Store Connect")
    end

    def collect_screenshots(options)
      return [] if options[:skip_screenshots]
      return collect_screenshots_for_languages(options[:screenshots_path], options[:ignore_language_directory_validation])
    end

    def collect_screenshots_for_languages(path, ignore_validation)
      screenshots = []
      extensions = '{png,jpg,jpeg}'

      available_languages = UploadScreenshots.available_languages.each_with_object({}) do |lang, lang_hash|
        lang_hash[lang.downcase] = lang
      end

      Loader.language_folders(path, ignore_validation).each do |lng_folder|
        language = File.basename(lng_folder)

        # Check to see if we need to traverse multiple platforms or just a single platform
        if language == Loader::APPLE_TV_DIR_NAME || language == Loader::IMESSAGE_DIR_NAME
          screenshots.concat(collect_screenshots_for_languages(File.join(path, language), ignore_validation))
          next
        end

        files = Dir.glob(File.join(lng_folder, "*.#{extensions}"), File::FNM_CASEFOLD).sort
        next if files.count == 0

        framed_screenshots_found = Dir.glob(File.join(lng_folder, "*_framed.#{extensions}"), File::FNM_CASEFOLD).count > 0

        UI.important("Framed screenshots are detected! 🖼 Non-framed screenshot files may be skipped. 🏃") if framed_screenshots_found

        language_dir_name = File.basename(lng_folder)

        if available_languages[language_dir_name.downcase].nil?
          UI.user_error!("#{language_dir_name} is not an available language. Please verify that your language codes are available in iTunesConnect. See https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/AppStoreTerritories.html for more information.")
        end

        language = available_languages[language_dir_name.downcase]

        files.each do |file_path|
          is_framed = file_path.downcase.include?("_framed.")
          is_watch = file_path.downcase.include?("watch")

          if framed_screenshots_found && !is_framed && !is_watch
            UI.important("🏃 Skipping screenshot file: #{file_path}")
            next
          end

          screenshots << AppScreenshot.new(file_path, language)
        end
      end

      # Checking if the device type exists in spaceship
      # Ex: iPhone 6.1 inch isn't supported in App Store Connect but need
      # to have it in there for frameit support
      unaccepted_device_shown = false
      screenshots.select! do |screenshot|
        exists = !screenshot.device_type.nil?
        unless exists
          UI.important("Unaccepted device screenshots are detected! 🚫 Screenshot file will be skipped. 🏃") unless unaccepted_device_shown
          unaccepted_device_shown = true

          UI.important("🏃 Skipping screenshot file: #{screenshot.path} - Not an accepted App Store Connect device...")
        end
        exists
      end

      return screenshots
    end

    # helper method so Spaceship::Tunes.client.available_languages is easier to test
    def self.available_languages
      if Helper.test?
        FastlaneCore::Languages::ALL_LANGUAGES
      else
        Spaceship::Tunes.client.available_languages
      end
    end
  end
end
