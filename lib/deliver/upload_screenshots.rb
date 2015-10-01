module Deliver
  # upload screenshots to iTunes Connect
  class UploadScreenshots
    def upload(options, screenshots)
      app = options[:app]

      v = app.edit_version
      raise "Could not find a version to edit for app '#{app.name}'".red unless v

      Helper.log.info "Starting with the upload of screenshots..."

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
      screenshots.each do |screenshot|
        indized[screenshot.language] ||= {}
        indized[screenshot.language][screenshot.device_type] ||= 0
        indized[screenshot.language][screenshot.device_type] += 1 # we actually start with 1... wtf iTC

        index = indized[screenshot.language][screenshot.device_type]

        if index > 5
          Helper.log.error "Too many screenshots found for device '#{screenshot.device_type}' in '#{screenshot.language}'"
          next
        end

        Helper.log.info "Uploading '#{screenshot.path}'..."
        v.upload_screenshot!(screenshot.path,
                             index,
                             screenshot.language,
                             screenshot.device_type)
      end

      Helper.log.info "Saving changes"
      v.save!
      Helper.log.info "Successfully uploaded screenshots to iTunes Connect".green
    end

    def collect_screenshots(options)
      screenshots = []
      extensions = '{png,jpg,jpeg}'
      Dir.glob(File.join(options[:screenshots_path], "*"), File::FNM_CASEFOLD).sort.each do |lng_folder|
        language = File.basename(lng_folder)

        files = Dir.glob(File.join(lng_folder, "*.#{extensions}"))
        next if files.count == 0

        prefer_framed = Dir.glob(File.join(lng_folder, '*_framed.#{extensions}')).count > 0

        files.each do |path|
          if prefer_framed && !path.downcase.include?("_framed.#{extensions}") && !path.downcase.include?("watch")
            next
          end

          screenshots << AppScreenshot.new(path, language)
        end
      end

      return screenshots
    end
  end
end
