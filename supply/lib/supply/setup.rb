module Supply
  class Setup
    def perform_download
      if File.exist?(metadata_path)
        UI.important("Metadata already exists at path '#{metadata_path}'")
        return
      end

      client.begin_edit(package_name: Supply.config[:package_name])

      client.listings.each do |listing|
        store_metadata(listing)
        create_screenshots_folder(listing)
        download_images(listing)
      end

      client.apks_version_codes.each do |apk_version_code|
        client.apk_listings(apk_version_code).each do |apk_listing|
          store_apk_listing(apk_listing)
        end
      end

      client.abort_current_edit

      UI.success("Successfully stored metadata in '#{metadata_path}'")
    end

    def store_metadata(listing)
      containing = File.join(metadata_path, listing.language)
      FileUtils.mkdir_p(containing)

      Supply::AVAILABLE_METADATA_FIELDS.each do |key|
        path = File.join(containing, "#{key}.txt")
        UI.message("Writing to #{path}...")
        File.open(path, 'w:UTF-8') { |file| file.write(listing.send(key)) }
      end
    end

    def download_images(listing)
      # We cannot download existing screenshots as they are compressed
      # But we can at least download the images
      require 'net/http'

      IMAGES_TYPES.each do |image_type|
        if ['featureGraphic'].include?(image_type)
          # we don't get all files in full resolution :(
          UI.message("Due to a limitation of the Google Play API, there is no way for `supply` to download your existing feature graphic. Please copy your feature graphic to `metadata/android/#{listing.language}/images/featureGraphic.png`")
          next
        end

        begin
          UI.message("Downloading #{image_type} for #{listing.language}...")

          url = client.fetch_images(image_type: image_type, language: listing.language).last
          next unless url

          path = File.join(metadata_path, listing.language, IMAGES_FOLDER_NAME, "#{image_type}.png")
          File.write(path, Net::HTTP.get(URI.parse(url)))
        rescue => ex
          UI.error(ex.to_s)
          UI.error("Error downloading '#{image_type}' for #{listing.language}...")
        end
      end
    end

    def create_screenshots_folder(listing)
      containing = File.join(metadata_path, listing.language)

      FileUtils.mkdir_p(File.join(containing, IMAGES_FOLDER_NAME))
      Supply::SCREENSHOT_TYPES.each do |screenshot_type|
        FileUtils.mkdir_p(File.join(containing, IMAGES_FOLDER_NAME, screenshot_type))
      end

      UI.message("Due to a limitation of the Google Play API, there is no way for `supply` to download your existing screenshots. Please copy your screenshots into `metadata/android/#{listing.language}/images/`")
    end

    def store_apk_listing(apk_listing)
      containing = File.join(metadata_path, apk_listing.language, CHANGELOGS_FOLDER_NAME)
      unless File.exist?(containing)
        FileUtils.mkdir_p(containing)
      end

      path = File.join(containing, "#{apk_listing.apk_version_code}.txt")
      UI.message("Writing to #{path}...")
      File.write(path, apk_listing.recent_changes)
    end

    private

    def metadata_path
      @metadata_path ||= Supply.config[:metadata_path]
      @metadata_path ||= "fastlane/metadata/android" if Helper.fastlane_enabled?
      @metadata_path ||= "metadata" unless Helper.fastlane_enabled?

      return @metadata_path
    end

    def client
      @client ||= Client.make_from_config
    end
  end
end
