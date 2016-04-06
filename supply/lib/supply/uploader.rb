module Supply
  class Uploader
    def perform_upload
      FastlaneCore::PrintTable.print_values(config: Supply.config, hide_keys: [:issuer], title: "Summary for supply #{Supply::VERSION}")

      client.begin_edit(package_name: Supply.config[:package_name])

      UI.user_error!("No local metadata found, make sure to run `supply init` to setup supply") unless metadata_path || Supply.config[:apk] || Supply.config[:apk_paths]

      if metadata_path
        UI.user_error!("Could not find folder #{metadata_path}") unless File.directory? metadata_path

        all_languages.each do |language|
          next if language.start_with?('.') # e.g. . or .. or hidden folders
          UI.message("Preparing to upload for language '#{language}'...")

          listing = client.listing_for_language(language)

          upload_metadata(language, listing) unless Supply.config[:skip_upload_metadata]
          upload_images(language) unless Supply.config[:skip_upload_images]
          upload_screenshots(language) unless Supply.config[:skip_upload_screenshots]
          upload_changelogs(language) unless Supply.config[:skip_upload_metadata]
        end
      end

      upload_binaries unless Supply.config[:skip_upload_apk]

      UI.message("Uploading all changes to Google Play...")
      client.commit_current_edit!
      UI.success("Successfully finished the upload to Google Play")
    end

    def upload_changelogs(language)
      client.apks_version_codes.each do |apk_version_code|
        upload_changelog(language, apk_version_code)
      end
    end

    def upload_changelog(language, apk_version_code)
      path = File.join(metadata_path, language, Supply::CHANGELOGS_FOLDER_NAME, "#{apk_version_code}.txt")
      if File.exist?(path)
        UI.message("Updating changelog for code version '#{apk_version_code}' and language '#{language}'...")
        apk_listing = ApkListing.new(File.read(path, encoding: 'UTF-8'), language, apk_version_code)
        client.update_apk_listing_for_language(apk_listing)
      end
    end

    def upload_metadata(language, listing)
      Supply::AVAILABLE_METADATA_FIELDS.each do |key|
        path = File.join(metadata_path, language, "#{key}.txt")
        listing.send("#{key}=".to_sym, File.read(path, encoding: 'UTF-8')) if File.exist?(path)
      end
      begin
        listing.save
      rescue Encoding::InvalidByteSequenceError => ex
        message = (ex.message || '').capitalize
        UI.user_error!("Metadata must be UTF-8 encoded. #{message}")
      end
    end

    def upload_images(language)
      Supply::IMAGES_TYPES.each do |image_type|
        search = File.join(metadata_path, language, Supply::IMAGES_FOLDER_NAME, image_type) + ".#{IMAGE_FILE_EXTENSIONS}"
        path = Dir.glob(search, File::FNM_CASEFOLD).last
        next unless path

        UI.message("Uploading image file #{path}...")
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
          UI.message("Uploading screenshot #{path}...")
          client.upload_image(image_path: File.expand_path(path),
                              image_type: screenshot_type,
                                language: language)
        end
      end
    end

    def upload_binaries
      apk_paths = [Supply.config[:apk]] unless (apk_paths = Supply.config[:apk_paths])

      apk_version_codes = []

      apk_paths.each do |apk_path|
        apk_version_codes.push(upload_binary_data(apk_path))
      end

      update_track(apk_version_codes)
    end

    private

    ##
    # Upload binary apk and obb and corresponding change logs with client
    #
    # @param [String] apk_path
    #    Path of the apk file to upload.
    #
    # @return [Integer] The apk version code returned after uploading, or nil if there was a problem
    def upload_binary_data(apk_path)
      apk_version_code = nil
      if apk_path
        UI.message("Preparing apk at path '#{apk_path}' for upload...")
        apk_version_code = client.upload_apk(apk_path)
        UI.user_error!("Could not upload #{apk_path}") unless apk_version_code

        upload_obbs(apk_path, apk_version_code)

        if metadata_path
          all_languages.each do |language|
            next if language.start_with?('.') # e.g. . or .. or hidden folders
            upload_changelog(language, apk_version_code)
          end
        end
      else
        UI.message("No apk file found, you can pass the path to your apk using the `apk` option")
      end
      apk_version_code
    end

    def update_track(apk_version_codes)
      UI.message("Updating track '#{Supply.config[:track]}'...")
      if Supply.config[:track].eql? "rollout"
        client.update_track(Supply.config[:track], Supply.config[:rollout], apk_version_codes)
      else
        client.update_track(Supply.config[:track], 1.0, apk_version_codes)
      end
    end

    def all_languages
      Dir.foreach(metadata_path).sort { |x, y| x <=> y }
    end

    def client
      @client ||= Client.make_from_config
    end

    def metadata_path
      Supply.config[:metadata_path]
    end

    # searches for obbs in the directory where the apk is located and
    # upload at most one main and one patch file. Do nothing if it finds
    # more than one of either of them.
    def upload_obbs(apk_path, apk_version_code)
      expansion_paths = find_obbs(apk_path)
      ['main', 'patch'].each do |type|
        if expansion_paths[type]
          upload_obb(expansion_paths[type], type, apk_version_code)
        end
      end
    end

    # @return a map of the obb paths for that apk
    # keyed by their detected expansion file type
    # E.g.
    # { 'main' => 'path/to/main.obb', 'patch' => 'path/to/patch.obb' }
    def find_obbs(apk_path)
      search = File.join(File.dirname(apk_path), '*.obb')
      paths = Dir.glob(search, File::FNM_CASEFOLD)
      expansion_paths = {}
      paths.each do |path|
        type = obb_expansion_file_type(path)
        next unless type
        if expansion_paths[type]
          UI.important("Can only upload one '#{type}' apk expansion. Skipping obb upload entirely.")
          UI.important("If you'd like this to work differently, please submit an issue.")
          return {}
        end
        expansion_paths[type] = path
      end
      expansion_paths
    end

    def upload_obb(obb_path, expansion_file_type, apk_version_code)
      UI.message("Uploading obb file #{obb_path}...")
      client.upload_obb(obb_file_path: obb_path,
                        apk_version_code: apk_version_code,
                        expansion_file_type: expansion_file_type)
    end

    def obb_expansion_file_type(obb_file_path)
      filename = File.basename(obb_file_path, ".obb")
      if filename.include?('main')
        'main'
      elsif filename.include?('patch')
        'patch'
      end
    end
  end
end
