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
    NON_LOCALISED_APP_VALUES = [:primary_category, :secondary_category,
                                :primary_first_sub_category, :primary_second_sub_category,
                                :secondary_first_sub_category, :secondary_first_sub_category
                               ]

    # Make sure to call `load_from_filesystem` before calling upload
    def upload(options)
      return if options[:skip_metadata]
      verify_available_languages!(options)

      app = options[:app]

      details = app.details
      v = app.edit_version

      (LOCALISED_VERSION_VALUES + LOCALISED_APP_VALUES).each do |key|
        current = options[key].to_s.strip
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
        current = options[key].to_s.strip
        next unless current.to_s.length > 0
        v.send("#{key}=", current) if NON_LOCALISED_VERSION_VALUES.include?(key)
        details.send("#{key}=", current) if NON_LOCALISED_APP_VALUES.include?(key)
      end

      v.release_on_approval = options[:automatic_release]

      set_review_information(v, options)
      set_app_rating(v, options)

      Helper.log.info "Uploading metadata to iTunes Connect"
      v.save!
      details.save!
      Helper.log.info "Successfully uploaded initial set of metadata to iTunes Connect".green
    end

    # Makes sure all languages we need are actually created
    def verify_available_languages!(options)
      return if options[:skip_metadata]

      # Collect all languages we need
      # We only care about languages from user provided values
      # as the other languages are on iTC already anyway
      v = options[:app].edit_version
      raise "Could not find a version to edit for app '#{options[:app].name}', the app metadata is read-only currently".red unless v

      enabled_languages = []
      LOCALISED_VERSION_VALUES.each do |key|
        current = options[key]
        next unless current && current.kind_of?(Hash)
        current.each do |language, value|
          enabled_languages << language unless enabled_languages.include?(language)
        end
      end

      if enabled_languages.count > 0
        v.create_languages(enabled_languages)
        lng_text = "language"
        lng_text += "s" if enabled_languages.count != 1
        Helper.log.info "Activating #{lng_text} #{enabled_languages.join(', ')}..."
        v.save!
      end
      true
    end

    # Loads the metadata files and stores them into the options object
    def load_from_filesystem(options)
      return if options[:skip_metadata]

      # Load localised data
      Dir.glob(File.join(options[:metadata_path], "*")).each do |lng_folder|
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
        path = File.join(options[:metadata_path], "#{key}.txt")
        next unless File.exist?(path)

        Helper.log.info "Loading '#{path}'..."
        options[key] ||= File.read(path)
      end
    end

    private

    def set_review_information(v, options)
      return unless options[:app_review_information]
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

    def set_app_rating(v, options)
      return unless options[:app_rating_config_path]

      require 'json'
      begin
        json = JSON.parse(File.read(options[:app_rating_config_path]))
      rescue => ex
        Helper.log.fatal ex.to_s
        raise "Error parsing JSON file at path '#{options[:app_rating_config_path]}'".red
      end
      v.update_rating(json)
    end
  end
end
