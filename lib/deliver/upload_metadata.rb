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

      details = app.details
      v = app.edit_version
      raise "Could not find a version to edit for app '#{app.name}'".red unless v

      # TODO: Create new language

      (LOCALISED_VERSION_VALUES + LOCALISED_APP_VALUES).each do |key|
        current = options[key]
        next unless current

        unless current.kind_of?(Hash)
          Helper.log.error "Error with provided '#{key}'. Must be a hash, the key being the language.".red
          next
        end

        current.each do |language, value|
          next unless value.to_s.length > 0
          v.send(key)[language] = value if LOCALISED_VERSION_VALUES.include?(key)
          details.send(key)[language] = value if LOCALISED_APP_VALUES.include?(key)
        end
      end

      (NON_LOCALISED_VERSION_VALUES + NON_LOCALISED_APP_VALUES).each do |key|
        current = options[key]
        next unless current.to_s.length > 0
        v.send("#{key}=", current) if NON_LOCALISED_VERSION_VALUES.include?(key)
        details.send("#{key}=", current) if NON_LOCALISED_APP_VALUES.include?(key)
      end

      set_review_information(v, options) if options[:app_review_information]

      Helper.log.info "Uploading metadata to iTunes Connect"
      v.save!
      details.save!
      Helper.log.info "Successfully uploaded initial set of metadata to iTunes Connect".green
    end

    # Loads the metadata files and stores them into the options object
    def load_from_filesystem(options)
      # Load localised data
      Dir.glob(File.join(options[:metadata_folder], "*")).each do |lng_folder|
        next unless File.directory?(lng_folder) # We don't want to read txt as they are non localised

        language = File.basename(lng_folder)

        (LOCALISED_VERSION_VALUES + LOCALISED_APP_VALUES).each do |key|
          path = File.join(lng_folder, "#{key}.txt")
          next unless File.exist?(path)

          Helper.log.info "Loading '#{path}'..."
          options[key] ||= {}
          options[key][language] ||= File.read(path)
        end
      end

      # Load non localised data
      (NON_LOCALISED_VERSION_VALUES + NON_LOCALISED_APP_VALUES).each do |key|
        path = File.join(options[:metadata_folder], "#{key}.txt")
        next unless File.exist?(path)

        Helper.log.info "Loading '#{path}'..."
        options[key] ||= File.read(path)
      end
    end

    private

    def set_review_information(v, options)
      info = options[:app_review_information]
      raise "`app_review_information` must be a hash" unless info.kind_of?(Hash)

      v.review_first_name = info[:first_name] if info[:first_name]
      v.review_last_name = info[:last_name] if info[:last_name]
      v.review_phone_number = info[:phone_number] if info[:phone_number]
      v.review_email = info[:email_address] if info[:email_address]
      v.review_demo_user = info[:demo_user] if info[:demo_user]
      v.review_demo_password = info[:demo_password] if info[:demo_password]
      v.review_notes = info[:notes] if info[:notes]
    end
  end
end
