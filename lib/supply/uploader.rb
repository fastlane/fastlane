module Supply
  class Uploader
    def perform_upload
      FastlaneCore::PrintTable.print_values(config: Supply.config, hide_keys: [:issuer], title: "Summary for sigh #{Supply::VERSION}")

      client.begin_edit(package_name: Supply.config[:package_name])

      raise "No local metadata found, make sure to run `supply init` to setup supply".red unless metadata_path || Supply.config[:apk]

      if metadata_path
        Dir.foreach(metadata_path) do |language|
          next if language.start_with?('.') # e.g. . or .. or hidden folders

          listing = client.listing_for_language(language)

          upload_metadata(language, listing) unless Supply.config[:skip_upload_metadata]
          upload_images(language) unless Supply.config[:skip_upload_images]
          upload_screenshots(language) unless Supply.config[:skip_upload_screenshots]
        end
      end

      upload_binary unless Supply.config[:skip_upload_apk]

      Helper.log.info "Uploading all changes to Google Play..."
      client.commit_current_edit!
      Helper.log.info "Successfully finished the upload to Google Play".green
    end

    def upload_metadata(language, listing)
      Helper.log.info "Loading metadata for language '#{language}'..."

      Supply::AVAILABLE_METADATA_FIELDS.each do |key|
        path = File.join(metadata_path, language, "#{key}.txt")
        listing.send("#{key}=".to_sym, File.read(path)) if File.exist?(path)
      end
      listing.save
    end

    def upload_images(language)
      Supply::IMAGES_TYPES.each do |image_type|
        search = File.join(metadata_path, language, Supply::IMAGES_FOLDER_NAME, image_type) + ".#{IMAGE_FILE_EXTENSIONS}"
        path = Dir.glob(search, File::FNM_CASEFOLD).last
        next unless path

        Helper.log.info "Uploading image file #{path}..."
        client.upload_image(image_path: File.expand_path(path),
                            image_type: image_type,
                              language: language)
      end
    end

    def upload_screenshots(language)
      Supply::SCREENSHOT_TYPES.each do |screenshot_type|
        search = File.join(metadata_path, language, Supply::IMAGES_FOLDER_NAME, screenshot_type, "*.#{IMAGE_FILE_EXTENSIONS}")
        paths = Dir.glob(search, File::FNM_CASEFOLD)
        next unless paths.count > 0

        client.clear_screenshots(image_type: screenshot_type, language: language)

        paths.sort.each do |path|
          Helper.log.info "Uploading screenshot #{path}..."
          client.upload_image(image_path: File.expand_path(path),
                              image_type: screenshot_type,
                                language: language)
        end
      end
    end

    def upload_binary
      if Supply.config[:apk]
        Helper.log.info "Preparing apk at path '#{Supply.config[:apk]}' for upload..."
        if Supply.config[:track].eql? "rollout"
          client.upload_apk_to_track_with_rollout(Supply.config[:apk], Supply.config[:track], Supply.config[:rollout])
        else
          client.upload_apk_to_track(Supply.config[:apk], Supply.config[:track])
        end
      else
        Helper.log.info "No apk file found, you can pass the path to your apk using the `apk` option"
      end
    end

    private

    def client
      @client ||= Client.new(path_to_key: Supply.config[:key],
                                   issuer: Supply.config[:issuer])
    end

    def metadata_path
      Supply.config[:metadata_path]
    end
  end
end
