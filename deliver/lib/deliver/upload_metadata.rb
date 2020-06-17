require_relative 'module'

module Deliver
  # upload description, rating, etc.
  class UploadMetadata
    # All the localised values attached to the version
    LOCALISED_VERSION_VALUES = {
      description: "description",
      keywords: "keywords",
      release_notes: "whatsNew",
      support_url: "supportUrl",
      marketing_url: "marketingUrl",
      promotional_text: "promotionalText"
    }

    # Everything attached to the version but not being localised
    NON_LOCALISED_VERSION_VALUES = {
      copyright: "copyright"
    }

    # Localised app details values
    LOCALISED_APP_VALUES = [:name, :subtitle, :privacy_url, :apple_tv_privacy_policy]

    # Non localized app details values
    NON_LOCALISED_APP_VALUES = [:primary_category, :secondary_category,
                                :primary_first_sub_category, :primary_second_sub_category,
                                :secondary_first_sub_category, :secondary_second_sub_category]

    # Trade Representative Contact Information values
    TRADE_REPRESENTATIVE_CONTACT_INFORMATION_VALUES = {
        trade_representative_trade_name: :trade_name,
        trade_representative_first_name: :first_name,
        trade_representative_last_name: :last_name,
        trade_representative_address_line_1: :address_line1,
        trade_representative_address_line_2: :address_line2,
        trade_representative_address_line_3: :address_line3,
        trade_representative_city_name: :city_name,
        trade_representative_state: :state,
        trade_representative_country: :country,
        trade_representative_postal_code: :postal_code,
        trade_representative_phone_number: :phone_number,
        trade_representative_email: :email_address,
        trade_representative_is_displayed_on_app_store: :is_displayed_on_app_store
    }

    # Review information values
    REVIEW_INFORMATION_VALUES_LEGACY = {
      review_first_name: :first_name,
      review_last_name: :last_name,
      review_phone_number: :phone_number,
      review_email: :email_address,
      review_demo_user: :demo_user,
      review_demo_password: :demo_password,
      review_notes: :notes
    }
    REVIEW_INFORMATION_VALUES = {
      first_name: "contactFirstName",
      last_name: "contactLastName",
      phone_number: "contactPhone",
      email_address: "contactEmail",
      demo_user: "demoAccountName",
      demo_password: "demoAccountPassword",
      notes: "notes"
    }

    # Localized app details values, that are editable in live state
    LOCALISED_LIVE_VALUES = [:description, :release_notes, :support_url, :marketing_url, :promotional_text, :privacy_url]

    # Non localized app details values, that are editable in live state
    NON_LOCALISED_LIVE_VALUES = [:copyright]

    # Directory name it contains trade representative contact information
    TRADE_REPRESENTATIVE_CONTACT_INFORMATION_DIR = "trade_representative_contact_information"

    # Directory name it contains review information
    REVIEW_INFORMATION_DIR = "review_information"

    ALL_META_SUB_DIRS = [TRADE_REPRESENTATIVE_CONTACT_INFORMATION_DIR, REVIEW_INFORMATION_DIR]

    # rubocop:disable Metrics/PerceivedComplexity

    require_relative 'loader'

    # Make sure to call `load_from_filesystem` before calling upload
    def upload(options)
      return if options[:skip_metadata]
      require 'pp'

      legacy_app = options[:app]
      app_id = legacy_app.apple_id
      app = Spaceship::ConnectAPI::App.get(app_id: app_id)

      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])

      app_store_version_localizations = verify_available_languages!(options, app) unless options[:edit_live]

      if options[:edit_live]
        # not all values are editable when using live_version
        version = app.get_ready_for_sale_app_store_version(platform: platform)
        localised_options = LOCALISED_LIVE_VALUES
        non_localised_options = NON_LOCALISED_LIVE_VALUES

        if v.nil?
          UI.message("Couldn't find live version, editing the current version on App Store Connect instead")
          version = app.get_prepare_for_submission_app_store_version(platform: platform)
          # we don't want to update the localised_options and non_localised_options
          # as we also check for `options[:edit_live]` at other areas in the code
          # by not touching those 2 variables, deliver is more consistent with what the option says
          # in the documentation
        end
      else
        version = app.get_prepare_for_submission_app_store_version(platform: platform)
        localised_options = (LOCALISED_VERSION_VALUES.keys + LOCALISED_APP_VALUES)
        non_localised_options = (NON_LOCALISED_VERSION_VALUES.keys + NON_LOCALISED_APP_VALUES)
      end

      localized_version_attributes_by_locale = {}

      individual = options[:individual_metadata_items] || []
      localised_options.each do |key|
        current = options[key]
        next unless current

        unless current.kind_of?(Hash)
          UI.error("Error with provided '#{key}'. Must be a hash, the key being the language.")
          next
        end

        current.each do |language, value|
          next unless value.to_s.length > 0
          strip_value = value.to_s.strip
          
          if LOCALISED_VERSION_VALUES.include?(key) && !strip_value.empty?
            attribute_name = LOCALISED_VERSION_VALUES[key]

            localized_version_attributes_by_locale[language] ||= {}
            localized_version_attributes_by_locale[language][attribute_name] = strip_value
          end

          if LOCALISED_APP_VALUES.include?(key)
            # puts "LOCALISED_APP_VALUES: NEED TO SEND #{key} #{language}"
            # puts "\t#{value}"
          end

        end
      end

      non_localized_version_attributes = {}
      non_localised_options.each do |key|
        strip_value = options[key].to_s.strip
        next unless strip_value.to_s.length > 0

        if NON_LOCALISED_VERSION_VALUES.include?(key) && !strip_value.empty?
          attribute_name = NON_LOCALISED_VERSION_VALUES[key]
          non_localized_version_attributes[attribute_name] = strip_value
        end
      end

      release_type = if options[:auto_release_date]
        non_localized_version_attributes['earliestReleaseDate'] = options[:auto_release_date]
        Spaceship::ConnectAPI::AppStoreVersion::ReleaseType::SCHEDULED
      elsif options[:automatic_release]
        Spaceship::ConnectAPI::AppStoreVersion::ReleaseType::AFTER_APPROVAL
      else
        Spaceship::ConnectAPI::AppStoreVersion::ReleaseType::MANUAL
      end
      non_localized_version_attributes['releaseType'] = release_type

      # Update app store version localizations
      app_store_version_localizations.each do |app_store_version_localization|
        attributes = localized_version_attributes_by_locale[app_store_version_localization.locale]
        if attributes
          UI.message("Uploading metadata to App Store Connect for localized version '#{app_store_version_localization.locale}'")
          app_store_version_localization.update(attributes: attributes)
        end
      end

      # Update app store version
      UI.message("Uploading metadata to App Store Connect for version")
      version.update(attributes: non_localized_version_attributes)

      # Update phased release
      unless options[:phased_release].nil?
        phased_release = version.get_app_store_version_phased_release rescue nil # returns no data error so need to rescue
        if !!options[:phased_release]
          unless phased_release
            UI.message("Creating phased release on App Store Connect")
            version.create_app_store_version_phased_release(attributes: {
              phasedReleaseState: Spaceship::ConnectAPI::AppStoreVersionPhasedRelease::PhasedReleaseState::INACTIVE
            })
          end
        elsif phased_release
          UI.message("Removing phased release on App Store Connect")
          phased_release.delete!
        end
      end

      # Update rating reset
      unless options[:reset_ratings].nil?
        reset_rating_request = version.get_reset_ratings_request rescue nil # returns no data error so need to rescue
        if !!options[:reset_ratings]
          unless reset_rating_request
            UI.message("Creating reset ratings request on App Store Connect")
            version.create_reset_ratings_request
          end
        elsif reset_rating_request
          UI.message("Removing reset ratings request on App Store Connect")
          reset_rating_request.delete!
        end
      end

      set_review_information(version, options)
      set_review_attachment_file(version, options)

      # set_app_rating(version, options)
      # set_trade_representative_contact_information(version, options)
    end

    # rubocop:enable Metrics/PerceivedComplexity

    # If the user is using the 'default' language, then assign values where they are needed
    def assign_defaults(options)
      # Normalizes languages keys from symbols to strings
      normalize_language_keys(options)

      # Build a complete list of the required languages
      enabled_languages = detect_languages(options)

      # Get all languages used in existing settings
      (LOCALISED_VERSION_VALUES.keys + LOCALISED_APP_VALUES).each do |key|
        current = options[key]
        next unless current && current.kind_of?(Hash)
        current.each do |language, value|
          enabled_languages << language unless enabled_languages.include?(language)
        end
      end

      # Check folder list (an empty folder signifies a language is required)
      ignore_validation = options[:ignore_language_directory_validation]
      Loader.language_folders(options[:metadata_path], ignore_validation).each do |lang_folder|
        next unless File.directory?(lang_folder) # We don't want to read txt as they are non localised
        language = File.basename(lang_folder)
        enabled_languages << language unless enabled_languages.include?(language)
      end

      return unless enabled_languages.include?("default")
      UI.message("Detected languages: " + enabled_languages.to_s)

      (LOCALISED_VERSION_VALUES.keys + LOCALISED_APP_VALUES).each do |key|
        current = options[key]
        next unless current && current.kind_of?(Hash)

        default = current["default"]
        next if default.nil?

        enabled_languages.each do |language|
          value = current[language]
          next unless value.nil?

          current[language] = default
        end
        current.delete("default")
      end
    end

    def detect_languages(options)
      # Build a complete list of the required languages
      enabled_languages = options[:languages] || []

      # Get all languages used in existing settings
      (LOCALISED_VERSION_VALUES.keys + LOCALISED_APP_VALUES).each do |key|
        current = options[key]
        next unless current && current.kind_of?(Hash)
        current.each do |language, value|
          enabled_languages << language unless enabled_languages.include?(language)
        end
      end

      # Check folder list (an empty folder signifies a language is required)
      ignore_validation = options[:ignore_language_directory_validation]
      Loader.language_folders(options[:metadata_path], ignore_validation).each do |lang_folder|
        next unless File.directory?(lang_folder) # We don't want to read txt as they are non localised

        language = File.basename(lang_folder)
        enabled_languages << language unless enabled_languages.include?(language)
      end

      # Mapping to strings because :default symbol can be passed in
      enabled_languages
        .map(&:to_s)
        .uniq
    end

    # Finding languages to enable
    def verify_available_languages!(options, app)
      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])
      version = app.get_prepare_for_submission_app_store_version(platform: platform)

      localizations = version.get_app_store_version_localizations

      languages = options[:languages] || []
      locales_to_enable = languages - localizations.map(&:locale)

      if locales_to_enable.count > 0
        lng_text = "language"
        lng_text += "s" if locales_to_enable.count != 1
        Helper.show_loading_indicator("Activating #{lng_text} #{locales_to_enable.join(', ')}...")

        locales_to_enable.each do |locale|
          version.create_app_store_version_localization(attributes: {
            locale: locale
          })
        end

        Helper.hide_loading_indicator

        # Refresh version localizations
        localizations = version.get_app_store_version_localizations
      end

      return localizations
    end

    # Makes sure all languages we need are actually created
    def verify_available_languages_old!(options)
      return if options[:skip_metadata]

      # Collect all languages we need
      # We only care about languages from user provided values
      # as the other languages are on iTC already anyway
      v = options[:app].edit_version(platform: options[:platform])
      UI.user_error!("Could not find a version to edit for app '#{options[:app].name}', the app metadata is read-only currently") unless v

      enabled_languages = options[:languages] || []
      LOCALISED_VERSION_VALUES.each do |key|
        current = options[key]
        next unless current && current.kind_of?(Hash)
        current.each do |language, value|
          language = language.to_s
          enabled_languages << language unless enabled_languages.include?(language)
        end
      end

      # Reject "default" language from getting enabled
      # because "default" is not an iTC language
      enabled_languages = enabled_languages.reject do |lang|
        lang == "default"
      end.uniq

      if enabled_languages.count > 0
        v.create_languages(enabled_languages)
        lng_text = "language"
        lng_text += "s" if enabled_languages.count != 1
        Helper.show_loading_indicator("Activating #{lng_text} #{enabled_languages.join(', ')}...")
        v.save!
        Helper.hide_loading_indicator
      end
      true
    end

    # Loads the metadata files and stores them into the options object
    def load_from_filesystem(options)
      return if options[:skip_metadata]

      # Load localised data
      ignore_validation = options[:ignore_language_directory_validation]
      Loader.language_folders(options[:metadata_path], ignore_validation).each do |lang_folder|
        language = File.basename(lang_folder)
        (LOCALISED_VERSION_VALUES.keys + LOCALISED_APP_VALUES).each do |key|
          path = File.join(lang_folder, "#{key}.txt")
          next unless File.exist?(path)

          UI.message("Loading '#{path}'...")
          options[key] ||= {}
          options[key][language] ||= File.read(path)
        end
      end

      # Load non localised data
      (NON_LOCALISED_VERSION_VALUES.keys + NON_LOCALISED_APP_VALUES).each do |key|
        path = File.join(options[:metadata_path], "#{key}.txt")
        next unless File.exist?(path)

        UI.message("Loading '#{path}'...")
        options[key] ||= File.read(path)
      end

      # Load trade representative contact information
      options[:trade_representative_contact_information] ||= {}
      TRADE_REPRESENTATIVE_CONTACT_INFORMATION_VALUES.values.each do |option_name|
        path = File.join(options[:metadata_path], TRADE_REPRESENTATIVE_CONTACT_INFORMATION_DIR, "#{option_name}.txt")
        next unless File.exist?(path)
        next if options[:trade_representative_contact_information][option_name].to_s.length > 0

        UI.message("Loading '#{path}'...")
        options[:trade_representative_contact_information][option_name] ||= File.read(path)
      end

      # Load review information
      options[:app_review_information] ||= {}
      REVIEW_INFORMATION_VALUES.keys.each do |option_name|
        path = File.join(options[:metadata_path], REVIEW_INFORMATION_DIR, "#{option_name}.txt")
        next unless File.exist?(path)
        next if options[:app_review_information][option_name].to_s.length > 0

        UI.message("Loading '#{path}'...")
        options[:app_review_information][option_name] ||= File.read(path)
      end
    end

    private

    # Normalizes languages keys from symbols to strings
    def normalize_language_keys(options)
      (LOCALISED_VERSION_VALUES.keys + LOCALISED_APP_VALUES).each do |key|
        current = options[key]
        next unless current && current.kind_of?(Hash)

        current.keys.each do |language|
          current[language.to_s] = current.delete(language)
        end
      end

      options
    end

    def set_trade_representative_contact_information(version, options)
      return unless options[:trade_representative_contact_information]

       # TODO: PUT THIS IN
       UI.error("We have temporarily disabled 'trade_representative_contact_information'. It will be back shortly 😊")

      # info = options[:trade_representative_contact_information]
      # UI.user_error!("`trade_representative_contact_information` must be a hash", show_github_issues: true) unless info.kind_of?(Hash)

      # TRADE_REPRESENTATIVE_CONTACT_INFORMATION_VALUES.each do |key, option_name|
      #   v.send("#{key}=", info[option_name].to_s.chomp) if info[option_name]
      # end
    end

    def set_review_information(version, options)
      return unless options[:app_review_information]
      info = options[:app_review_information]
      UI.user_error!("`app_review_information` must be a hash", show_github_issues: true) unless info.kind_of?(Hash)

      attributes = {}
      REVIEW_INFORMATION_VALUES.each do |key, attribute_name|
        strip_value = info[key].to_s.strip
        attributes[attribute_name] = strip_value unless strip_value.empty?
      end

      if !attributes["demoAccountName"].to_s.empty? && !attributes["demoAccountPassword"].to_s.empty?
        attributes["demoAccountRequired"] = true
      else
        attributes["demoAccountRequired"] = false
      end

      UI.message("Uploading app review information to App Store Connect")
      app_store_review_detail = version.get_app_store_review_detail
      app_store_review_detail.update(attributes: attributes)
    end

    def set_review_attachment_file(version, options)
      return unless options[:app_review_attachment_file]

      app_store_review_detail = version.get_app_store_review_detail
      app_review_attachments = app_store_review_detail.get_app_review_attachments

      app_review_attachments.each do |app_review_attachment|
        UI.message("Removing previous review attachment file from App Store Connect")
        app_review_attachment.delete!
      end

      UI.message("Uploading review attachment file to App Store Connect")
      app_store_review_detail.upload_attachment(path: options[:app_review_attachment_file])
    end

    def set_app_rating(version, options)
      return unless options[:app_rating_config_path]

      # TODO: PUT THIS IN
      UI.error("We have temporarily disabled 'app_rating_config_path'. It will be back shortly 😊")

      # require 'json'
      # begin
      #   json = JSON.parse(File.read(options[:app_rating_config_path]))
      # rescue => ex
      #   UI.error(ex.to_s)
      #   UI.user_error!("Error parsing JSON file at path '#{options[:app_rating_config_path]}'")
      # end
      # UI.message("Setting the app's age rating...")
      # v.update_rating(json)
    end
  end
end
