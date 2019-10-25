module Supply
  class Uploader
    def perform_upload
      FastlaneCore::PrintTable.print_values(config: Supply.config, hide_keys: [:issuer], mask_keys: [:json_key_data], title: "Summary for supply #{Fastlane::VERSION}")

      client.begin_edit(package_name: Supply.config[:package_name])

      verify_config!

      apk_version_codes = []
      apk_version_codes.concat(upload_apks) unless Supply.config[:skip_upload_apk]
      apk_version_codes.concat(upload_bundles) unless Supply.config[:skip_upload_aab]
      upload_mapping(apk_version_codes)

      apk_version_codes.concat(Supply.config[:version_codes_to_retain]) if Supply.config[:version_codes_to_retain]

      if ((!Supply.config[:skip_upload_metadata] || !Supply.config[:skip_upload_changelogs] || !Supply.config[:skip_upload_screenshots]) && metadata_path)
        UI.user_error!("Could not find folder #{metadata_path}") unless File.directory?(metadata_path)

        release_notes = []
        all_languages.each do |language|
          next if language.start_with?('.') # e.g. . or .. or hidden folders
          UI.message("Preparing to upload for language '#{language}'...")

          listing = client.listing_for_language(language)
          
          upload_metadata(language, listing) unless Supply.config[:skip_upload_metadata]
          upload_images(language) unless Supply.config[:skip_upload_images]
          upload_screenshots(language) unless Supply.config[:skip_upload_screenshots]
          release_notes << upload_changelog(language) unless Supply.config[:skip_upload_changelogs]
        end

        upload_changelogs(release_notes, apk_version_codes) unless Supply.config[:skip_upload_changelogs]
      end

      # Only update tracks if we have version codes
      # Updating a track with empty version codes can completely clear out a track
      update_track(apk_version_codes) unless apk_version_codes.empty?

      if !Supply.config[:rollout].nil? && Supply.config[:version_code].to_s != "" && Supply.config[:track].to_s != ""
        update_rollout
      end

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

    def update_rollout
      UI.message("Updating #{Supply.config[:version_code]}'s rollout to '#{Supply.config[:rollout]}' on track '#{Supply.config[:track]}'...")

      tracks = @client.tracks(Supply.config[:track])
      UI.user_error!("Unable to find the requested track - '#{Supply.config[:track]}'") if tracks.length == 0

      track = tracks.first
      releases = track.releases.select { |r| r.version_codes.include?(Supply.config[:version_code]) }

      version_codes = Supply.config
      if Supply.config[:version_code]
        releases = releases.select { |r| r.version_codes.include?(Supply.config[:version_code]) }
      end

      release = releases.first
      if release
        completed = Supply.config[:rollout].to_f == 1
        release.send("user_fraction=", completed ? nil : Supply.config[:rollout])
        release.send("status=", 'completed') if completed

        track.releases.delete_if { |r| !r.version_codes.include?(Supply.config[:version_code]) } if completed
      else
        UI.user_error!("Unable to find version code '#{Supply.config[:version_code]}' in track '#{Supply.config[:track]}'")
      end

      client.update_track(Supply.config[:track], track)
    end

    def verify_config!
      unless metadata_path || Supply.config[:apk] || Supply.config[:apk_paths] || Supply.config[:aab] || Supply.config[:aab_paths] || (Supply.config[:track] && Supply.config[:track_promote_to])
        UI.user_error!("No local metadata, apks, aab, or track to promote were found, make sure to run `fastlane supply init` to setup supply")
      end

      # Can't upload both at apk and aab at same time
      # Need to error out users when there both apks and aabs are detected
      apk_paths = [Supply.config[:apk], Supply.config[:apk_paths]].flatten.compact
      could_upload_apk = !apk_paths.empty? && !Supply.config[:skip_upload_apk]
      could_upload_aab = Supply.config[:aab] && !Supply.config[:skip_upload_aab]
      if could_upload_apk && could_upload_aab
        UI.user_error!("Cannot provide both apk(s) and aab - use `skip_upload_apk`, `skip_upload_aab`, or  make sure to remove any existing .apk or .aab files that are no longer needed")
      end

      if Supply.config[:release_status] == 'draft' && Supply.config[:rollout]
        UI.user_error!(%(Cannot specify rollout percentage when the release status is set to 'draft'))
      end

      unless Supply.config[:version_codes_to_retain].nil?
        Supply.config[:version_codes_to_retain] = Supply.config[:version_codes_to_retain].map(&:to_i)
      end
    end

    def promote_track
      track_from = @client.tracks(Supply.config[:track]).first
      unless track_from
        UI.user_error!("Cannot promote from track '#{Supply.config[:track]}' - track doesn't exist")
      end

      releases = track_from.releases.select do |release|
        release.version_codes.include?(Supply.config[:version_code])
      end if Supply.config[:version_code].to_s != ""

      if releases.size == 0
        UI.user_error!("Track '#{Supply.config[:track]}' doesn't have any releases")
      elsif releases.size > 1
        UI.user_error!("Track '#{Supply.config[:track]}' has more than one release - use :version_code to filter the release to promote")
      end

      release = track_from.releases.first
      track_to = @client.tracks(Supply.config[:track_promote_to]).first

      if track_to
        track_to.releases = [release]
      else
        track_to = AndroidPublisher::Track.new(
          track: Supply.config[:track_promote_to],
          releases: [release]
        )
      end

      client.update_track(Supply.config[:track_promote_to], track_to)
    end

    def upload_changelog(language)
      path = File.join(Supply.config[:metadata_path], language, Supply::CHANGELOGS_FOLDER_NAME, "#{Supply.config[:version_code]}.txt")
      changelog_text = ''
      if File.exist?(path)
        changelog_text = File.read(path, encoding: 'UTF-8')
      else
        UI.user_error!(%(Cannot update changelog for '#{language}', as the path '#{path}' does not exist.))
      end

      AndroidPublisher::LocalizedText.new({
        language: language,
        text: changelog_text
      })
    end

    def upload_changelogs(release_notes, version_codes = [])
      track_release = AndroidPublisher::TrackRelease.new({
        name: Supply.config[:version_code],
        release_notes: release_notes,
        status: Supply.config[:release_status]
      })

      track_release.version_codes = version_codes if version_codes.length > 0
      track_release.user_fraction = Supply.config[:rollout] unless Supply.config[:rollout].nil? && Supply.config[:track] == "inProgress"

      track = AndroidPublisher::Track.new({
        track: Supply.config[:track],
        releases: [track_release]
      })

      client.upload_changelogs(track)
    end

    def upload_changelogs_DEPRECATED(language)
      client.apks_version_codes.each do |apk_version_code|
        upload_changelog(language, apk_version_code)
      end
      client.aab_version_codes.each do |aab_version_code|
        upload_changelog(language, aab_version_code)
      end
    end

    def upload_changelog_DEPRECATED(language, version_code)
      path = File.join(metadata_path, language, Supply::CHANGELOGS_FOLDER_NAME, "#{version_code}.txt")
      if File.exist?(path)
        UI.message("Updating changelog for code version '#{version_code}' and language '#{language}'...")
        apk_listing = ApkListing.new(File.read(path, encoding: 'UTF-8'), language, version_code)
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

    def upload_apks
      apk_paths = [Supply.config[:apk]] unless (apk_paths = Supply.config[:apk_paths])
      apk_paths.compact!

      apk_version_codes = []

      apk_paths.each do |apk_path|
        apk_version_codes.push(upload_binary_data(apk_path))
      end

      return apk_version_codes
    end

    def upload_mapping(apk_version_codes)
      mapping_paths = [Supply.config[:mapping]] unless (mapping_paths = Supply.config[:mapping_paths])
      mapping_paths.zip(apk_version_codes).each do |mapping_path, version_code|
        if mapping_path
          client.upload_mapping(mapping_path, version_code)
        end
      end
    end

    def upload_bundles
      aab_paths = [Supply.config[:aab]] unless (aab_paths = Supply.config[:aab_paths])
      return [] unless aab_paths
      aab_paths.compact!

      aab_version_codes = []

      aab_paths.each do |aab_path|
        UI.message("Preparing aab at path '#{aab_path}' for upload...")
        bundle_version_code = client.upload_bundle(aab_path)

        # if metadata_path
        #   all_languages.each do |language|
        #     next if language.start_with?('.') # e.g. . or .. or hidden folders
        #     upload_changelog(language, bundle_version_code)
        #   end
        # end

        aab_version_codes.push(bundle_version_code)
      end

      return aab_version_codes
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

        if Supply.config[:obb_main_references_version] && Supply.config[:obb_main_file_size]
          update_obb(apk_version_code,
                     'main',
                     Supply.config[:obb_main_references_version],
                     Supply.config[:obb_main_file_size])
        end

        if Supply.config[:obb_patch_references_version] && Supply.config[:obb_patch_file_size]
          update_obb(apk_version_code,
                     'patch',
                     Supply.config[:obb_patch_references_version],
                     Supply.config[:obb_patch_file_size])
        end

        upload_obbs(apk_path, apk_version_code)

        # if metadata_path
        #   all_languages.each do |language|
        #     next if language.start_with?('.') # e.g. . or .. or hidden folders
        #     upload_changelog(language, apk_version_code)
        #   end
        # end
      else
        UI.message("No apk file found, you can pass the path to your apk using the `apk` option")
      end

      UI.message("\tVersion Code: #{apk_version_code}")
      apk_version_code
    end

    def update_obb(apk_version_code, expansion_file_type, references_version, file_size)
      UI.message("Updating '#{expansion_file_type}' expansion file from version '#{references_version}'...")
      client.update_obb(apk_version_code,
                        expansion_file_type,
                        references_version,
                        file_size)
    end

    def update_track(apk_version_codes)
      return if apk_version_codes.empty?

      UI.message("Updating track '#{Supply.config[:track]}'...")
      check_superseded_tracks(apk_version_codes) if Supply.config[:check_superseded_tracks]

      track_release = AndroidPublisher::TrackRelease.new(
        name: Supply.config[:version_name],
        # TODO: Put in release notes here
        release_notes: [],
        status: "completed",
        version_codes: apk_version_codes
      )

      if Supply.config[:rollout]
        track_release.status = "inProgress"
        track_release.user_fraction = Supply.config[:rollout].to_f
      end

      track = AndroidPublisher::Track.new(
        track: Supply.config[:track],
        releases: [track_release]
      )

      client.update_track(Supply.config[:track], track)
    end

    # Remove any version codes that is:
    #  - Lesser than the greatest of any later (i.e. production) track
    #  - Or lesser than the currently being uploaded if it's in an earlier (i.e. alpha) track
    def check_superseded_tracks(apk_version_codes)
      UI.message("Checking superseded tracks, uploading '#{apk_version_codes}' to '#{Supply.config[:track]}'...")
      max_apk_version_code = apk_version_codes.max
      max_tracks_version_code = nil

      tracks = Supply::AVAILABLE_TRACKS
      config_track_index = tracks.index(Supply.config[:track])

      # Custom "closed" tracks are now allowed (https://support.google.com/googleplay/android-developer/answer/3131213)
      # Custom tracks have an equal level with alpha (alpha is considered a closed track as well)
      # If a track index is not found, we will assume is a custom track so an alpha index is given
      config_track_index = tracks.index("alpha") unless config_track_index

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
