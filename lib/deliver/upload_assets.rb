module Deliver
  class UploadAssets
    def upload(options)
      app = options[:app]

      v = app.edit_version
      UI.user_error!("Could not find a version to edit for app '#{app.name}'") unless v

      if options[:app_icon]
        UI.message("Uploading app icon...")
        v.upload_large_icon!(options[:app_icon])
      end

      if options[:apple_watch_app_icon]
        UI.message("Uploading apple watchapp icon...")
        v.upload_watch_icon!(options[:apple_watch_app_icon])
      end

      v.save!
    end
  end
end
