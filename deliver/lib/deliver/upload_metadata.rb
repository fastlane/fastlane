require_relative 'module'

module Deliver
  # upload description, rating, etc.
  class UploadMetadata
    # All the localised values attached to the version
    LOCALISED_VERSION_VALUES = [:description, :keywords, :release_notes, :support_url, :marketing_url, :promotional_text]

    # Everything attached to the version but not being localised
    NON_LOCALISED_VERSION_VALUES = [:copyright]

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
    REVIEW_INFORMATION_VALUES = {
      review_first_name: :first_name,
      review_last_name: :last_name,
      review_phone_number: :phone_number,
      review_email: :email_address,
      review_demo_user: :demo_user,
      review_demo_password: :demo_password,
      review_notes: :notes
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
      # it is not possible to create new languages, because
      # :keywords is not write-able on published versions
      # therefore skip it.
      verify_available_languages!(options) unless options[:edit_live]

      app = options[:app]

      details = app.details
      if options[:edit_live]
        # not all values are editable when using live_version
        v = app.live_version(platform: options[:platform])
        localised_options = LOCALISED_LIVE_VALUES
        non_localised_options = NON_LOCALISED_LIVE_VALUES

        if v.nil?
          UI.message("Couldn't find live version, editing the current version on App Store Connect instead")
          v = app.edit_version(platform: options[:platform])
          # we don't want to update the localised_options and non_localised_options
          # as we also check for `options[:edit_live]` at other areas in the code
          # by not touching those 2 variables, deliver is more consistent with what the option says
          # in the documentation
        end
      else
        v = app.edit_version(platform: options[:platform])
        localised_options = (LOCALISED_VERSION_VALUES + LOCALISED_APP_VALUES)
        non_localised_options = (NON_LOCALISED_VERSION_VALUES + NON_LOCALISED_APP_VALUES)
      end

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
          if individual.include?(key.to_s)
            upload_individual_item(app, v, language, key, strip_value)
          else
            v.send(key)[language] = strip_value if LOCALISED_VERSION_VALUES.include?(key)
            details.send(key)[language] = strip_value if LOCALISED_APP_VALUES.include?(key)
          end
        end
      end

      non_localised_options.each do |key|
        current = options[key].to_s.strip
        next unless current.to_s.length > 0
        v.send("#{key}=", current) if NON_LOCALISED_VERSION_VALUES.include?(key)
        details.send("#{key}=", current) if NON_LOCALISED_APP_VALUES.include?(key)
      end

      v.release_on_approval = options[:automatic_release]
      v.auto_release_date = options[:auto_release_date] unless options[:auto_release_date].nil?
      v.toggle_phased_release(enabled: !!options[:phased_release]) unless options[:phased_release].nil?

      set_trade_representative_contact_information(v, options)
      set_review_information(v, options)
      set_app_rating(v, options)
      v.ratings_reset = options[:reset_ratings] unless options[:reset_ratings].nil?

      set_review_attachment_file(v, options)

      Helper.show_loading_indicator("Uploading metadata to App Store Connect")
      v.save!
      Helper.hide_loading_indicator
      begin
        details.save!
        UI.success("Successfully uploaded set of metadata to App Store Connect")
      rescue Spaceship::TunesClient::ITunesConnectError => e
        # This makes sure that we log invalid app names as user errors
        # If another string needs to be checked here we should
        # figure out a more generic way to handle these cases.
        if e.message.include?('App Name cannot be longer than 50 characters') || e.message.include?('The app name you entered is already being used')
          UI.error("Error in app name.  Try using 'individual_metadata_items' to identify the problem language.")
          UI.user_error!(e.message)
        else
          raise e
        end
      end
    end

    # Uploads metadata individually by language to help identify exactly which items have issues
    def upload_individual_item(app, version, language, key, value)
      details = app.details
      version.send(key)[language] = value if LOCALISED_VERSION_VALUES.include?(key)
      details.send(key)[language] = value if LOCALISED_APP_VALUES.include?(key)
      Helper.show_loading_indicator("Uploading #{language} #{key} to App Store Connect")
      version.save!
      Helper.hide_loading_indicator
      begin
        details.save!
        UI.success("Successfully uploaded #{language} #{key} to App Store Connect")
      rescue Spaceship::TunesClient::ITunesConnectError => e
        UI.error("Error in #{language} #{key}: \n#{value}")
        UI.error(e.message) # Don't use user_error to allow all values to get checked
      end
    end

    # rubocop:enable Metrics/PerceivedComplexity

    # If the user is using the 'default' language, then assign values where they are needed
    def assign_defaults(options)
      # Normalizes languages keys from symbols to strings
      normalize_language_keys(options)

      # Build a complete list of the required languages
      enabled_languages = detect_languages(options)

      # Get all languages used in existing settings
      (LOCALISED_VERSION_VALUES + LOCALISED_APP_VALUES).each do |key|
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

      (LOCALISED_VERSION_VALUES + LOCALISED_APP_VALUES).each do |key|
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
      (LOCALISED_VERSION_VALUES + LOCALISED_APP_VALUES).each do |key|
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

    # Makes sure all languages we need are actually created
    def verify_available_languages!(options)
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
        (LOCALISED_VERSION_VALUES + LOCALISED_APP_VALUES).each do |key|
          path = File.join(lang_folder, "#{key}.txt")
          next unless File.exist?(path)

          UI.message("Loading '#{path}'...")
          options[key] ||= {}
          options[key][language] ||= File.read(path)
        end
      end

      # Load non localised data
      (NON_LOCALISED_VERSION_VALUES + NON_LOCALISED_APP_VALUES).each do |key|
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
      REVIEW_INFORMATION_VALUES.values.each do |option_name|
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
      (LOCALISED_VERSION_VALUES + LOCALISED_APP_VALUES).each do |key|
        current = options[key]
        next unless current && current.kind_of?(Hash)

        current.keys.each do |language|
          current[language.to_s] = current.delete(language)
        end
      end

      options
    end

    def set_trade_representative_contact_information(v, options)
      return unless options[:trade_representative_contact_information]
      info = options[:trade_representative_contact_information]
      UI.user_error!("`trade_representative_contact_information` must be a hash", show_github_issues: true) unless info.kind_of?(Hash)

      TRADE_REPRESENTATIVE_CONTACT_INFORMATION_VALUES.each do |key, option_name|
        v.send("#{key}=", info[option_name].to_s.chomp) if info[option_name]
      end
    end

    def set_review_information(v, options)
      return unless options[:app_review_information]
      info = options[:app_review_information]
      UI.user_error!("`app_review_information` must be a hash", show_github_issues: true) unless info.kind_of?(Hash)

      REVIEW_INFORMATION_VALUES.each do |key, option_name|
        v.send("#{key}=", info[option_name].to_s.chomp) if info[option_name]
      end
      v.review_user_needed = (v.review_demo_user.to_s.chomp + v.review_demo_password.to_s.chomp).length > 0
    end

    def set_review_attachment_file(v, options)
      return unless options[:app_review_attachment_file]
      v.upload_review_attachment!(options[:app_review_attachment_file])
    end

    def set_app_rating(v, options)
      return unless options[:app_rating_config_path]

      require 'json'
      begin
        json = JSON.parse(File.read(options[:app_rating_config_path]))
      rescue => ex
        UI.error(ex.to_s)
        UI.user_error!("Error parsing JSON file at path '#{options[:app_rating_config_path]}'")
      end
      UI.message("Setting the app's age rating...")
      v.update_rating(json)
    end
  end
end
