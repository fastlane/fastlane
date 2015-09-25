module Deliver
  # upload description, rating, etc.
  class UploadMetadata
    # All the localised values attached to the version
    LOCALISED_VERSION_VALUES = [:description, :keywords, :release_notes, :support_url, :marketing_url]

    # Everything attached to the version but not being localised
    NON_LOCALISED_VERSION_VALUES = [:copyright]

    # Localised app details values
    LOCALISED_APP_VALUES = [:name, :privacy_url]

    # Non localized app details values
    NON_LOCALISED_APP_VALUES = [:primary_category, :secondary_category]

    # Make sure to call `load_from_filesystem` before calling upload
    def upload(options)
      app = options[:app]

      v = app.edit_version
      raise "Could not find a version to edit for app '#{app.name}'".red unless v

      # TODO: Create new language

      LOCALISED_VERSION_VALUES.each do |key|
        value = options[key]
        next unless value

        unless value.kind_of?(Hash)
          Helper.log.error "Error with provided '#{key}'. Must be a hash, the key being the language.".red
          next
        end

        value.each do |language, value|
          v.send(key)[language] = value
        end
      end

      NON_LOCALISED_VERSION_VALUES.each do |key|
        value = options[key]
        next unless value
        v.send("#{key}=", value)
      end

      Helper.log.info "Uploading metadata to iTunes Connect"
      v.save!
      Helper.log.info "Successfully uploaded initial set of metadata to iTunes Connect".green
    end

    # Loads the metadata files and stores them into the options object
    def load_from_filesystem(options)
      # Load localised data
      Dir.glob(File.join(options[:metadata_folder], "*")).each do |lng_folder|
        next if lng_folder.include?"." # We don't want to read txt as they are non localised
        language = File.basename(lng_folder)

        LOCALISED_VERSION_VALUES.each do |key|
          path = File.join(lng_folder, "#{key}.txt")
          next unless File.exist?(path)

          Helper.log.info "Loading '#{path}'..."
          options[key] ||= {}
          options[key][language] ||= File.read(path)
        end
      end

      # Load non localised data
      NON_LOCALISED_VERSION_VALUES.each do |key|
        path = File.join(options[:metadata_folder], "#{key}.txt")
        next unless File.exist?(path)

        Helper.log.info "Loading '#{path}'..."
        options[key] ||= File.read(path) # we can use the `lng`, it will be converted later
      end
    end
  end
end
