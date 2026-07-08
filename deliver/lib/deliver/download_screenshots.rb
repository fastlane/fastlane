require_relative 'module'
require 'spaceship'
require 'open-uri'

module Deliver
  class DownloadScreenshots
    def self.run(options, path)
      UI.message("Downloading all existing screenshots...")
      download(options, path)
      UI.success("Successfully downloaded all existing screenshots")
    rescue => ex
      UI.error(ex)
      UI.error("Couldn't download already existing screenshots from App Store Connect.")
    end

    def self.download(options, folder_path)
      app = Deliver.cache[:app]

      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])
      if options[:use_live_version]
        version = app.get_live_app_store_version(platform: platform)
        UI.user_error!("Could not find a live version on App Store Connect. Try using '--use_live_version false'") if version.nil?
      else
        version = app.get_edit_app_store_version(platform: platform)
        UI.user_error!("Could not find an edit version on App Store Connect. Try using '--use_live_version true'") if version.nil?
      end

      localizations = version.get_app_store_version_localizations
      threads = []
      localizations.each do |localization|
        threads << Thread.new do
          download_screenshots(folder_path, localization)
        end
      end
      threads.each(&:join)
    end

    def self.download_screenshots(folder_path, localization)
      language = localization.locale
      screenshot_sets = localization.get_app_screenshot_sets
      screenshot_sets.each do |screenshot_set|
        screenshot_set.app_screenshots.each_with_index do |screenshot, index|
          file_name = [index, screenshot_set.screenshot_display_type, index].join("_")
          original_file_extension = File.extname(screenshot.file_name).strip.downcase[1..-1]
          file_name += "." + original_file_extension

          url = screenshot.image_asset_url(type: original_file_extension)
          next if url.nil?

          UI.message("Downloading existing screenshot '#{file_name}' for language '#{language}'")

          # If the screen shot is for an appleTV we need to store it in a way that we'll know it's an appleTV
          # screen shot later as the screen size is the same as an iPhone 6 Plus in landscape.
          if screenshot_set.apple_tv?
            containing_folder = File.join(folder_path, "appleTV", language)
          else
            containing_folder = File.join(folder_path, language)
          end

          if screenshot_set.imessage?
            containing_folder = File.join(folder_path, "iMessage", language)
          end

          begin
            FileUtils.mkdir_p(containing_folder)
          rescue
            # if it's already there
          end

          path = File.join(containing_folder, file_name)
          File.binwrite(path, URI.open(url).read)
        end
      end
    end
  end
end
