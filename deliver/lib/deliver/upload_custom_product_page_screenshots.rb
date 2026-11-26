require 'fastlane_core'
require 'spaceship/tunes/tunes'

require_relative 'module'
require_relative 'upload_screenshots'
require_relative 'sync_screenshots'

module Deliver
  # Upload screenshots to a Custom Product Page (CPP) instead of the edit App Store version.
  # The default and `overwrite_screenshots` modes reuse UploadScreenshots, and
  # `sync_screenshots` reuses SyncScreenshots: only the localizations differ.
  class UploadCustomProductPageScreenshots < UploadScreenshots
    def upload(options, screenshots)
      return if options[:skip_screenshots]

      if options[:edit_live]
        UI.user_error!("'custom_product_page_id' cannot be used with 'edit_live': screenshots go to a version of the custom product page, not to the live app version")
      end

      cpp_id = options[:custom_product_page_id].to_s.strip
      UI.user_error!("You must provide :custom_product_page_id to upload screenshots to a custom product page") if cpp_id.empty?

      sync = SyncScreenshots.new if options[:sync_screenshots]
      sync&.ensure_beta_enabled!

      app = Deliver.cache[:app]
      cpp = fetch_custom_product_page(app, cpp_id)
      version = fetch_editable_version(cpp)

      UI.important("Will begin uploading screenshots for Custom Product Page '#{cpp.name}' (version #{version.version}, #{version.state}) on App Store Connect")

      screenshots_per_language = screenshots.group_by(&:language)
      localizations = enable_localizations(version, screenshots_per_language.keys)

      if sync
        sync.sync_localizations(localizations, screenshots)
        UI.success("Successfully synced screenshots to Custom Product Page '#{cpp.name}' on App Store Connect")
        return
      end

      # Overwrite deletes the screenshot sets of the languages being uploaded
      delete_screenshots(localizations, screenshots_per_language) if options[:overwrite_screenshots]

      upload_screenshots(localizations, screenshots_per_language, options[:screenshot_processing_timeout])

      Helper.with_loading_indicator("Sorting screenshots uploaded...") do
        sort_screenshots(localizations)
      end

      UI.success("Successfully uploaded screenshots to Custom Product Page '#{cpp.name}' on App Store Connect")
    end

    private

    def fetch_custom_product_page(app, cpp_id)
      cpp = Spaceship::ConnectAPI::AppCustomProductPage.get(app_custom_product_page_id: cpp_id, includes: "app").first
      UI.user_error!("Could not find Custom Product Page with id '#{cpp_id}'") unless cpp

      if cpp.app.nil? || cpp.app.id != app.id
        UI.user_error!("Custom Product Page '#{cpp.name}' (#{cpp_id}) does not belong to app '#{app.name}' (#{app.id})")
      end

      cpp
    end

    # The newest version whose screenshots can still be changed
    def fetch_editable_version(cpp)
      versions = Spaceship::ConnectAPI::AppCustomProductPageVersion.all(app_custom_product_page_id: cpp.id)
      UI.user_error!("Custom Product Page '#{cpp.name}' has no versions to upload to") if versions.nil? || versions.empty?

      version = versions.select(&:editable?).max_by { |v| v.version.to_i }
      if version.nil?
        states = versions.map { |v| "version #{v.version}: #{v.state}" }.join(', ')
        editable = Spaceship::ConnectAPI::AppCustomProductPageVersion::EDITABLE_STATES.join(' or ')
        UI.user_error!("Custom Product Page '#{cpp.name}' has no version in #{editable} (#{states}). Create a new version of the page in App Store Connect and try again.")
      end

      version
    end

    # Creates the localizations missing for `locales` and returns all localizations of the version
    def enable_localizations(version, locales)
      localizations = version.get_localizations
      locales_to_enable = locales - localizations.map(&:locale)
      return localizations if locales_to_enable.empty?

      lng_text = locales_to_enable.count == 1 ? "language" : "languages"
      Helper.with_loading_indicator("Activating #{lng_text} #{locales_to_enable.join(', ')} for Custom Product Page version #{version.version}...") do
        locales_to_enable.each do |locale|
          version.create_localization(attributes: { locale: locale })
        end
      end

      version.get_localizations
    end
  end
end
