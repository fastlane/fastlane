module Supply
  class Uploader
    def perform_upload
      client.begin_edit(package_name: Supply.config[:package_name])

      # Metadata
      load_local_metadata

      # pkg
      upload_binary

      Helper.log.info "Uploading changes to Google Play..."
      client.commit_current_edit!
      Helper.log.info "Successfully finished the upload to Google Play".green
    end

    def load_local_metadata
      Dir.foreach(metadata_path) do |language|
        next if language.start_with?('.') # e.g. . or .. or hidden folders
        Helper.log.info "Loading metadata for language '#{language}'..."

        listing = client.listing_for_language(language)
        Supply::AVAILABLE_METADATA_FIELDS.each do |key|
          path = File.join(metadata_path, language, "#{key}.txt")
          listing.send("#{key}=".to_sym, File.read(path)) if File.exist?(path)
        end
        listing.save
      end
    end

    def upload_binary
      if Supply.config[:apk]
        Helper.log.info "Preparing apk at path '#{Supply.config[:apk]}' for upload..."
        client.upload_apk_to_track(Supply.config[:apk], Supply.config[:track])
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
