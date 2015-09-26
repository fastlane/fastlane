module Deliver
  # upload screenshots to iTunes Connect
  class UploadScreenshots
    def upload(options, screenshots)
      app = options[:app]

      v = app.edit_version
      raise "Could not find a version to edit for app '#{app.name}'".red unless v

      Helper.log.info "Starting with the upload of screenshots..."

      indized = {} # per language and device type
      screenshots.each do |screenshot|
        indized[screenshot.language] ||= {}
        indized[screenshot.language][screenshot.device_type] ||= 0
        indized[screenshot.language][screenshot.device_type] += 1 # we actually start with 1... wtf iTC

        index = indized[screenshot.language][screenshot.device_type]

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
      Dir.glob(File.join(options[:screenshots_path], "*")) do |lng_folder|
        language = File.basename(lng_folder)

        files = Dir.glob(File.join(lng_folder, '*.png'))
        next if files.count == 0

        files.each do |path|
          screenshots << AppScreenshot.new(path, language)
        end
      end

      return screenshots
    end
  end
end
