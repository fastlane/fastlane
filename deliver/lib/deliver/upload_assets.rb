require_relative 'module'

module Deliver
  class UploadAssets
    SUPPORTED_ICON_EXTENSIONS = [".png", ".jpg", ".jpeg"]
    def upload(options)
      return if options[:edit_live]
      app = options[:app]
      app_modified = false

      v = app.edit_version(platform: options[:platform])
      UI.user_error!("Could not find a version to edit for app '#{app.name}'") unless v

      if options[:app_icon]
        UI.message("Uploading app icon...")
        v.upload_large_icon!(options[:app_icon])
        app_modified = true
      end

      if options[:apple_watch_app_icon]
        UI.message("Uploading apple watchapp icon...")
        v.upload_watch_icon!(options[:apple_watch_app_icon])
        app_modified = true
      end

      v.save! if app_modified
    end
  end
end
