module Deliver
  # used to maintain 2 set of MD5s one for local one for remotes
  class ScreenshotMD5s
    def initialize
      @checksums = {}
    end

    # index is implicitly computed
    def add_md5(language, device_type, md5)
      @checksums[language] ||= {}
      @checksums[language][device_type] ||= []
      @checksums[language][device_type] << md5
    end

    def matches_md5?(language, device_type, md5, index)
      @checksums[language] &&
      @checksums[language][device_type] &&
      @checksums[language][device_type].include?(md5) &&
      @checksums[language][device_type].index(md5) + 1 == index
    end
  end

  # upload screenshots to iTunes Connect
  class UploadScreenshots
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def upload(options, screenshots)
      return if options[:skip_screenshots]

      app = options[:app]

      v = app.edit_version
      UI.user_error!("Could not find a version to edit for app '#{app.name}'") unless v

      @checksums_local = ScreenshotMD5s.new
      @checksums_remote = ScreenshotMD5s.new

      screenshots.each do |screenshot|
        md5 = Spaceship::Utilities.md5digest(screenshot.path)
        @checksums_local.add_md5(screenshot.language, screenshot.device_type, md5)
      end

      # If we have nothing to delete, there's no point in calling save!
      nothing_to_delete = true

      v.screenshots.each do |lang, screenshots_for_lang|
        screenshots_for_lang.each do |current|
          original_file_name = current.original_file_name
          matched = original_file_name.match(/ftl_([0-9a-f]{32})_(.*)/)

          if matched
            md5 = matched[1]
            original_file_name = matched[2]
          end
          # store remote checksum. We will need it later to determine if we have to upload screenshot
          @checksums_remote.add_md5(current.language, current.device_type, md5)
          # Remove from ITC non existing locally screenshots
          # Or screenshots that have wrong order (compare indexes)
          # Or screenshots that we haven't uploaded through spaceship
          next if md5 && @checksums_local.matches_md5?(current.language, current.device_type, md5, current.sort_order)

          UI.message("Deleting screenshot: #{original_file_name}, order: #{current.sort_order} for language: #{current.language}")
          nothing_to_delete = false
          v.upload_screenshot!(nil, current.sort_order, current.language, current.device_type)
        end
      end

      if screenshots.empty?
        UI.message("Nothing to upload...")
      else
        UI.message("Starting with the upload of screenshots...")
      end

      # Now, fill in the new ones
      indized = {} # per language and device type

      screenshots_per_language = screenshots.group_by(&:language)
      screenshots_per_language.each do |language, screenshots_for_language|
        UI.message("Uploading #{screenshots_for_language.length} screenshots for language #{language}")

        # If we don't have anything to upload, there's no point in calling save!
        nothing_to_upload = true

        screenshots_for_language.each do |screenshot|
          indized[screenshot.language] ||= {}
          indized[screenshot.language][screenshot.device_type] ||= 0
          indized[screenshot.language][screenshot.device_type] += 1 # we actually start with 1... wtf iTC

          index = indized[screenshot.language][screenshot.device_type]

          if index > 5
            UI.error("Too many screenshots found for device '#{screenshot.device_type}' in '#{screenshot.language}'")
            next
          end

          md5 = Spaceship::Utilities.md5digest(screenshot.path)

          device_type = screenshot.device_type

          if @checksums_remote.matches_md5?(screenshot.language, device_type, md5, index)
            UI.message("Screenshot #{screenshot.path} already uploaded. Skipping")
          else
            nothing_to_upload = false
            UI.message("Uploading '#{screenshot.path}'...")
            v.upload_screenshot!(screenshot.path,
                                 index,
                                 screenshot.language,
                                 screenshot.device_type)
          end
        end
        # ideally we should only save once, but itunes server can't cope it seems
        # so we save per language. See issue #349
        if nothing_to_upload
          UI.message("Nothing changed. Skipping save")
        else
          UI.message("Saving changes")
          v.save!
        end
      end

      UI.message("Nothing to delete...") if nothing_to_delete
      # we need extra save! in case if we only deleting screenshots - nothing to upload
      # we are skipping save if nothing to upload and nothing to delete
      if screenshots.empty? && !nothing_to_delete
        UI.message("Saving changes")
        v.save!
      end
      UI.success("Screenshot sync (upload/delete) finished.")
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def collect_screenshots(options)
      return [] if options[:skip_screenshots]
      return collect_screenshots_for_languages(options[:screenshots_path])
    end

    def collect_screenshots_for_languages(path)
      screenshots = []
      extensions = '{png,jpg,jpeg}'

      Loader.language_folders(path).each do |lng_folder|
        language = File.basename(lng_folder)

        # Check to see if we need to traverse multiple platforms or just a single platform
        if language == Loader::APPLE_TV_DIR_NAME
          screenshots.concat(collect_screenshots_for_languages(File.join(path, language)))
          next
        end

        files = Dir.glob(File.join(lng_folder, "*.#{extensions}"), File::FNM_CASEFOLD)
        next if files.count == 0

        prefer_framed = Dir.glob(File.join(lng_folder, "*_framed.#{extensions}"), File::FNM_CASEFOLD).count > 0

        UI.important("Framed screenshots are detected! 🖼 Non-framed screenshot files may be skipped. 🏃") if prefer_framed

        language = File.basename(lng_folder)
        files.each do |file_path|
          is_framed = file_path.downcase.include?("_framed.")
          is_watch = file_path.downcase.include?("watch")

          if prefer_framed && !is_framed && !is_watch
            UI.important("🏃 Skipping screenshot file: #{file_path}")
            next
          end

          screenshots << AppScreenshot.new(file_path, language)
        end
      end

      return screenshots
    end
  end
end
