module Deliver
  # upload screenshots to iTunes Connect
  class UploadScreenshots
    def upload(options, screenshots)
      return if options[:skip_screenshots]

      app = options[:app]

      v = app.edit_version
      UI.user_error!("Could not find a version to edit for app '#{app.name}'") unless v

      UI.message("Starting with the upload of screenshots...")

      # First, clear all previously uploaded screenshots, but only where we have new ones
      # screenshots.each do |screenshot|
      #   to_remove = v.screenshots[screenshot.language].find_all do |current|
      #     current.device_type == screenshot.device_type
      #   end
      #   to_remove.each { |t| t.reset! }
      # end
      # This part is not working yet...

      # Now, fill in the new ones
      indized = {} # per language and device type

      progress_file = 'progress.dump'

      unless options[:skip_uploaded_screenshots]
        if File.exist?(progress_file)
          File.delete(progress_file)
      end
      progress = File.exist?(progress_file) ? Marshal.load(File.read(progress_file)) : []

      last_error = false
      screenshots_per_language = screenshots.group_by(&:language)
      screenshots_per_language.each do |language, screenshots_for_language|
        next if progress.include?(language)
        begin
          UI.message("Uploading #{screenshots_for_language.length} screenshots for language #{language}")
          screenshots_for_language.each do |screenshot|
            indized[screenshot.language] ||= {}
            indized[screenshot.language][screenshot.device_type] ||= 0
            indized[screenshot.language][screenshot.device_type] += 1 # we actually start with 1... wtf iTC

            index = indized[screenshot.language][screenshot.device_type]

            if index > 5
              UI.error("Too many screenshots found for device '#{screenshot.device_type}' in '#{screenshot.language}'")
              next
            end

            UI.message("Uploading '#{screenshot.path}'...")
            v.upload_screenshot!(screenshot.path,
                                 index,
                                 screenshot.language,
                                 screenshot.device_type)
          end
          # ideally we should only save once, but itunes server can't cope it seems
          # so we save per language. See issue #349
          UI.message("Saving changes")
          v.save!
          progress << language
          File.open(progress_file, 'w') { |f| f.write(Marshal.dump(progress)) }
        rescue
          UI.error("An error occurred for language #{language}, will try again next time")
          last_error = $!
          # something failed, try again next time
        end
      end
      if last_error
        raise last_error
      end
      UI.success("Successfully uploaded screenshots to iTunes Connect")
    end

    def collect_screenshots(options)
      return [] if options[:skip_screenshots]
      return collect_screenshots_for_languages(options[:screenshots_path])
    end

    def collect_screenshots_for_languages(path)
      screenshots = []
      extensions = '{png,jpg,jpeg}'
      last_error = false
      Loader.language_folders(path).each do |lng_folder|
        language = File.basename(lng_folder)

        # Check to see if we need to traverse multiple platforms or just a single platform
        if language == Loader::APPLE_TV_DIR_NAME
          screenshots.concat(collect_screenshots_for_languages(File.join(path, language)))
          next
        end

        files = Dir.glob(File.join(lng_folder, "*.#{extensions}"), File::FNM_CASEFOLD).sort
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

          begin
            screenshots << AppScreenshot.new(file_path, language)
          rescue
            last_error = $!
            UI.error(last_error)
          end
        end
      end

      if last_error
        raise last_error
      end
      return screenshots
    end
  end
end
