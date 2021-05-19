require_relative 'upload_metadata'

module Deliver
  module Languages
    # 2020-08-24 - Available locales are not available as an endpoint in App Store Connect
    # Update with Spaceship::Tunes.client.available_languages.sort (as long as endpoint is avilable)
    ALL_LANGUAGES = %w[ar-SA ca cs da de-DE el en-AU en-CA en-GB en-US es-ES es-MX fi fr-CA fr-FR he hi hr hu id it ja ko ms nl-NL no pl pt-BR pt-PT ro ru sk sv th tr uk vi zh-Hans zh-Hant]
  end
end

module Deliver
  class PrepareLanguages
    attr_reader :enabled_languages
    attr_reader :app_store_version_localizations
    attr_reader :app_info_localizations

    def prepare!(options)
      app = options[:app]

      detected_languages = detect_languages(options)

      @app_store_version_localizations = verify_available_version_languages!(options, app, detected_languages) unless options[:edit_live]
      @app_info_localizations = verify_available_info_languages!(options, app, detected_languages) unless options[:edit_live]

      @enabled_languages = (
        detected_languages +
        app_store_version_localizations.map(&:locale) +
        app_info_localizations.map(&:locale)
      ).uniq
    end

    def detect_languages(options)
      # Build a complete list of the required languages
      enabled_languages = options[:languages] || []

      # Get all languages used in existing settings
      (Deliver::UploadMetadata::LOCALISED_VERSION_VALUES.keys + Deliver::UploadMetadata::LOCALISED_APP_VALUES.keys).each do |key|
        current = options[key]
        next unless current && current.kind_of?(Hash)
        current.each do |language, value|
          enabled_languages << language unless enabled_languages.include?(language)
        end
      end

      # Check folder list (an empty folder signifies a language is required)
      ignore_validation = options[:ignore_language_directory_validation]
      Loader.language_folders(options[:metadata_path], ignore_validation).each do |lang_folder|
        enabled_languages << lang_folder.basename unless enabled_languages.include?(lang_folder.basename)
      end

      # Mapping to strings because :default symbol can be passed in
      return enabled_languages
             .map(&:to_s)
             .uniq
    end

    # Finding languages to enable
    def verify_available_info_languages!(options, app, languages)
      app_info = app.fetch_edit_app_info

      unless app_info
        UI.user_error!("Cannot update languages - could not find an editable info")
        return
      end

      localizations = app_info.get_app_info_localizations

      languages = (languages || []).reject { |lang| lang == "default" }
      locales_to_enable = languages - localizations.map(&:locale)

      if locales_to_enable.count > 0
        lng_text = "language"
        lng_text += "s" if locales_to_enable.count != 1
        Helper.show_loading_indicator("Activating info #{lng_text} #{locales_to_enable.join(', ')}...")

        locales_to_enable.each do |locale|
          app_info.create_app_info_localization(attributes: {
            locale: locale
          })
        end

        Helper.hide_loading_indicator

        # Refresh version localizations
        localizations = app_info.get_app_info_localizations
      end

      return localizations
    end

    # Finding languages to enable
    def verify_available_version_languages!(options, app, languages)
      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])
      version = app.get_edit_app_store_version(platform: platform)

      unless version
        UI.user_error!("Cannot update languages - could not find an editable version for '#{platform}'")
        return
      end

      localizations = version.get_app_store_version_localizations

      languages = (languages || []).reject { |lang| lang == "default" }
      locales_to_enable = languages - localizations.map(&:locale)

      if locales_to_enable.count > 0
        lng_text = "language"
        lng_text += "s" if locales_to_enable.count != 1
        Helper.show_loading_indicator("Activating version #{lng_text} #{locales_to_enable.join(', ')}...")

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
  end
end
