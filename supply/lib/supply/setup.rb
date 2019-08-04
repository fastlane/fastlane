module Supply
  class Setup
    def perform_download
      UI.message("🕗  Downloading metadata, images, screenshots ...")

      if File.exist?(metadata_path)
        UI.important("Metadata already exists at path '#{metadata_path}'")
        return
      end

      client.begin_edit(package_name: Supply.config[:package_name])

      client.listings.each do |listing|
        store_metadata(listing)
        download_images(listing)
      end

      client.release_listings(Supply.config[:version]).each do |release_listing|
        store_release_listing(release_listing)
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

    def download_images(listing)
      UI.message("🖼️  Downloading images (#{listing.language})")

      require 'net/http'

      allowed_imagetypes = [Supply::IMAGES_TYPES, Supply::SCREENSHOT_TYPES].flatten

      allowed_imagetypes.each do |image_type|
        begin
          path = File.join(metadata_path, listing.language, IMAGES_FOLDER_NAME, image_type)

          p = Pathname.new(path)
          if IMAGES_TYPES.include?(image_type) # IMAGE_TYPES are stored in locale/images location
            FileUtils.mkdir_p(p.dirname.to_s)
          else # SCREENSHOT_TYPES go under their respective folders.
            FileUtils.mkdir_p(p.to_s)
          end

          UI.message("Downloading `#{image_type}` for #{listing.language}...")

          urls = client.fetch_images(image_type: image_type, language: listing.language)
          next if urls.nil? || urls.empty?

          image_counter = 1 # Used to prefix the downloaded files, so order is preserved.
          urls.each do |url|
            url_params = url.match("=.*")
            if !url_params.nil? && url_params.length == 1
              UI.verbose("Initial URL received: '#{url}'")
              url = url.gsub(url_params.to_s, "") # Remove everything after '=' (if present). This ensures webp is converted to png/jpg (https://www.howtogeek.com/325864/how-to-save-googles-webp-images-as-jpeg-or-png/)
              UI.verbose("Removed params ('#{url_params}') from the URL")
              UI.verbose("URL after removing params: '#{url}'")
            end

            url = "#{url}=s0" # '=s0' param ensures full image size is returned (https://github.com/fastlane/fastlane/pull/14322#issuecomment-473012462)

            if IMAGES_TYPES.include?(image_type) # IMAGE_TYPES are stored in locale/images location
              file_path = "#{path}.#{FastImage.type(url)}"
            else # SCREENSHOT_TYPES go under their respective folders.
              file_path = "#{path}/#{image_counter}_#{listing.language}.#{FastImage.type(url)}"
            end

            File.binwrite(file_path, Net::HTTP.get(URI.parse(url)))

            UI.message("\tDownloaded - #{file_path}")

            image_counter += 1
          end
        rescue => ex
          UI.error(ex.to_s)
          UI.error("Error downloading '#{image_type}' for #{listing.language}...")
        end
      end
    end

    def store_release_listing(release_listing)
      UI.message("🔨  Downloading changelogs (#{release_listing.language}, #{release_listing.version})")

      containing = File.join(metadata_path, release_listing.language, CHANGELOGS_FOLDER_NAME)
      unless File.exist?(containing)
        FileUtils.mkdir_p(containing)
      end

      path = File.join(containing, "#{release_listing.version}.txt")
      path = File.join(containing, "<version_number>.txt")
      UI.message("Writing to #{path}...")
      File.write(path, release_listing.release_notes)
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
