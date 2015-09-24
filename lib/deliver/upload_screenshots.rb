module Deliver
  # upload screenshots to iTunes Connect
  class UploadScreenshots
    LOCALISED_VALUES = [:description, :name, :keywords]

    def run(options)
      app = options[:app]

      v = app.edit_version || app.live_version # TODO: get changes from work macbook here
      raise "Could not find a version to edit for app '#{app.name}'".red unless v

      Helper.log.info "Starting with the upload of screenshots..."

      du = Spaceship::Tunes.client.du_client

      Dir.glob(File.join(options[:screenshots_folder], "*")) do |lng_folder|
        lng = File.basename(lng_folder)
        language = Spaceship::Tunes::LanguageConverter.from_standard_to_itc(lng) # de-DE => German

        indized = {} # per language

        Dir.glob(File.join(lng_folder, '*.png')).each do |path|
          Helper.log.info "Uploading '#{path}'"
          device_type = AppScreenshot.new(path).device_type

          indized[device_type] ||= 0
          indized[device_type] += 1 # we actually start with 1... wtf iTC
          v.upload_screenshot!(path, indized[device_type], language, device_type)
        end
      end
      
      Helper.log.info "Saving changes"
      v.save!
      Helper.log.info "Successfully uploaded screenshots to iTunes Connect".green
    end
  end
end
