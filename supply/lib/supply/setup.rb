module Supply
  class Setup
    def perform_download(image_format = "png", remove_alpha = false)
      UI.message("🕗  Downloading metadata, images, screenshots...")

      if File.exist?(metadata_path)
        UI.important("Metadata already exists at path '#{metadata_path}'")
        return
      end

      client.begin_edit(package_name: Supply.config[:package_name])

      client.listings.each do |listing|
        store_metadata(listing)
        download_images(listing, image_format, remove_alpha)
      end

      client.apks_version_codes.each do |apk_version_code|
        client.apk_listings(apk_version_code).each do |apk_listing|
          store_apk_listing(apk_listing)
        end
      end

      client.abort_current_edit

      UI.success("✅  Successfully stored metadata in '#{metadata_path}'")
    end

    def store_metadata(listing)
      UI.message("📝  Downloading metadata (#{listing.language})")

      containing = File.join(metadata_path, listing.language)
      FileUtils.mkdir_p(containing)

      Supply::AVAILABLE_METADATA_FIELDS.each do |key|
        path = File.join(containing, "#{key}.txt")
        UI.message("Writing to #{path}...")
        File.open(path, 'w:UTF-8') { |file| file.write(listing.send(key)) }
      end
    end

    def download_images(listing, image_format = "png", remove_alpha = false)
      UI.message("🖼️  Downloading images (#{listing.language})")

      require 'net/http'

      allowed_imagetypes = [Supply::IMAGES_TYPES, Supply::SCREENSHOT_TYPES].flatten

      allowed_imagetypes.each do |image_type|
        begin
          UI.message("Downloading `#{image_type}` for #{listing.language}...")

          urls = client.fetch_images(image_type: image_type, language: listing.language)
          next if urls.nil? || urls.empty?

          image_counter = 1 # Used to prefix the downloaded files, so order is preserved.
          urls.each do |url|
            url = "#{url}=w6000-h6000" # using huge dimentions intentionally so Google returns the images in their original size they were uploaded
            
            if IMAGES_TYPES.include?(image_type) # IMAGE_TYPES are stored in locale/images location
              path = File.join(metadata_path, listing.language, IMAGES_FOLDER_NAME, "#{image_type}.#{image_format}") 
            else # all other screenshot types goes under their respective folders.
              path = File.join(metadata_path, listing.language, IMAGES_FOLDER_NAME, image_type, "#{image_counter}_#{listing.language}.#{image_format}")
            end

            p = Pathname.new(path)
            FileUtils.mkdir_p(p.dirname.to_s)

            File.write(path, Net::HTTP.get(URI.parse(url))) # Write to tmp `path`

            image = MiniMagick::Image.open(path)
            image_details = JSON.parse(image.details.to_json, symbolize_names: true)

            # remove alpha
            is_alpha_present = image_details.keys.any? { |k| k == :Alpha }
            image.alpha('remove') if is_alpha_present && remove_alpha

            # convert image
            image.format(image_format) # Properly formatting the final image. Sometimes "jpg" or "webp" or "png" formats are returned by Google.
            image.write(path) # Properly formatted file is written to disk

            UI.message("\tDownloaded  - #{path}")
            UI.message("\t\tAlpha removed") if is_alpha_present && remove_alpha

            image_counter += 1
          end
        rescue => ex
          UI.error(ex.to_s)
          UI.error("Error downloading '#{image_type}' for #{listing.language}...")
        end
      end
    end

    def store_apk_listing(apk_listing)
      UI.message("🔨  Downloading changelogs (#{apk_listing.language}, #{apk_listing.apk_version_code})")

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
