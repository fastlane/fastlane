module Deliver
  class UploadAssets
    def upload(options)
      app = options[:app]

      v = app.edit_version
      UI.user_error!("Could not find a version to edit for app '#{app.name}'") unless v

      # check if we need to call save! and waste time
      save_needed = false

      if options[:app_icon]
        if v.upload_large_icon!(options[:app_icon])
          UI.message("Uploading app icon...")
          save_needed = true
        else
          UI.message("App icon not changed. Skipping upload")
        end
      end

      if options[:apple_watch_app_icon]
        if v.upload_watch_icon!(options[:apple_watch_app_icon])
          UI.message("Uploading apple watchapp icon...")
          save_needed = true
        else
          UI.message("Watchapp icon not changed. Skipping upload")
        end
      end

      v.save! if save_needed
    end
  end
end
