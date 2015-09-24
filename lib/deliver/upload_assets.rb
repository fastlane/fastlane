module Deliver
  class UploadAssets
    def upload(options)
      app = options[:app]

      v = app.edit_version || app.live_version # TODO: get changes from work macbook here
      raise "Could not find a version to edit for app '#{app.name}'".red unless v

      if options[:app_icon]
        Helper.log.info "Uploading app icon..."
        v.upload_large_icon!(options[:app_icon])
      end

      if options[:apple_watch_app_icon]
        Helper.log.info "Uploading apple watchapp icon..."
        v.upload_watch_icon!(options[:apple_watch_app_icon])
      end

      v.save!
    end
  end
end