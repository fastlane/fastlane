module Supply
  class Uploader
    def perform_upload
      FastlaneCore::PrintTable.print_values(config: Supply.config, hide_keys: [:issuer], mask_keys: [:json_key_data], title: "Summary for supply #{Fastlane::VERSION}")

      client.begin_edit(package_name: Supply.config[:package_name])

      UI.user_error!("No local metadata found, make sure to run `fastlane supply init` to setup supply") unless metadata_path || Supply.config[:apk] || Supply.config[:apk_paths]

      if metadata_path
        UI.user_error!("Could not find folder #{metadata_path}") unless File.directory?(metadata_path)

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

      promote_track if Supply.config[:track_promote_to]

      if Supply.config[:validate_only]
        UI.message("Validating all changes with Google Play...")
        client.validate_current_edit!
        UI.success("Successfully validated the upload to Google Play")
      else
        UI.message("Uploading all changes to Google Play...")
        client.commit_current_edit!
        UI.success("Successfully finished the upload to Google Play")
      end
    end

    def promote_track
      version_codes = client.track_version_codes(Supply.config[:track])
      # the actual value passed for the rollout argument does not matter because it will be ignored by the Google Play API
      # but it has to be between 0.0 and 1.0 to pass the validity check. So we are passing the default value 0.1
      client.update_track(Supply.config[:track], 0.1, nil)
      client.update_track(Supply.config[:track_promote_to], Supply.config[:rollout] || 0.1, version_codes)
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

      mapping_paths = [Supply.config[:mapping]] unless (mapping_paths = Supply.config[:mapping_paths])
      mapping_paths.zip(apk_version_codes).each do |mapping_path, version_code|
        if mapping_path
          client.upload_mapping(mapping_path, version_code)
        end
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
      check_superseded_tracks(apk_version_codes) if Supply.config[:check_superseded_tracks]

      if Supply.config[:track].eql?("rollout")
        client.update_track(Supply.config[:track], Supply.config[:rollout] || 0.1, apk_version_codes)
      else
        client.update_track(Supply.config[:track], 1.0, apk_version_codes)
      end
    end

    # Remove any version codes that is:
    #  - Lesser than the greatest of any later (i.e. production) track
    #  - Or lesser than the currently being uploaded if it's in an earlier (i.e. alpha) track
    def check_superseded_tracks(apk_version_codes)
      UI.message("Checking superseded tracks, uploading '#{apk_version_codes}' to '#{Supply.config[:track]}'...")
      max_apk_version_code = apk_version_codes.max
      max_tracks_version_code = nil

      tracks = ["production", "rollout", "beta", "alpha"]
      config_track_index = tracks.index(Supply.config[:track])

      tracks.each_index do |track_index|
        track = tracks[track_index]
        track_version_codes = client.track_version_codes(track).sort
        UI.verbose("Found '#{track_version_codes}' on track '#{track}'")

        next if track_index.eql?(config_track_index)
        next if track_version_codes.empty?

        if max_tracks_version_code.nil?
          max_tracks_version_code = track_version_codes.max
        end

        removed_version_codes = track_version_codes.take_while do |v|
          v < max_tracks_version_code || (v < max_apk_version_code && track_index > config_track_index)
        end

        next if removed_version_codes.empty?

        keep_version_codes = track_version_codes - removed_version_codes
        max_tracks_version_code = keep_version_codes[0] unless keep_version_codes.empty?
        client.update_track(track, 1.0, keep_version_codes)
        UI.message("Superseded track '#{track}', removed '#{removed_version_codes}'")
      end
    end

    # returns only language directories from metadata_path
    def all_languages
      Dir.entries(metadata_path)
         .select { |f| File.directory?(File.join(metadata_path, f)) }
         .reject { |f| f.start_with?('.') }
         .sort { |x, y| x <=> y }
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
