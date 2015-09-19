module Supply
  class Setup
    def perform_download
      client.begin_edit(package_name: Supply.config[:package_name])

      client.listings.each do |listing|
        store_metadata(listing)

        store_screenshots(listing.language)
      end

      client.abort_current_edit

      Helper.log.info "Successfully stored metadata in '#{metadata_path}'".green
    end

    def store_metadata(listing)
      containing = File.join(metadata_path, listing.language)
      FileUtils.mkdir_p(containing)

      Supply::AVAILABLE_METADATA_FIELDS.each do |key|
        path = File.join(containing, "#{key}.txt")
        Helper.log.info "Writing to #{path}..."
        File.write(path, listing.send(key))
      end
    end

    def store_screenshots(language)
      Supply::SCREENSHOT_TYPES.each do |image_type|
        urls = client.fetch_screenshots(image_type: image_type,
                                           language: language)

        urls.each_with_index do |url, index|
          if image_type.include?("Screenshots")
            FileUtils.mkdir_p(File.join(metadata_path, language, image_type))
            path = File.join(metadata_path, language, image_type, "#{index}.png")
          else
            path = File.join(metadata_path, language, "#{image_type}.png")
          end

          Helper.log.info "Writing to #{path}..."

          File.write(path, Net::HTTP.get(URI(url)))
        end
      end
    end

    private

    def metadata_path
      @metadata_path ||= Supply.config[:metadata_path]
      @metadata_path ||= "fastlane/metadata/android" if Helper.fastlane_enabled?
      @metadata_path ||= "metadata" unless Helper.fastlane_enabled?
    end

    def client
      @client ||= Client.new(path_to_key: Supply.config[:key],
                                   issuer: Supply.config[:issuer])
    end
  end
end
