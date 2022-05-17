require 'fastlane_core'
require 'spaceship'

require_relative 'module'

module Deliver
  # rubocop:disable Metrics/ClassLength
  class UploadAppClipDefaultExperienceMetadata
    require_relative 'loader'

    def upload_metadata(options)
      # app clip default experience metadata is not editable in a live version
      return if options[:edit_live]

      # validate options
      subtitle_localized = options[:app_clip_default_experience_subtitle]
      action = options[:app_clip_default_experience_action]
      UI.user_error!("You must provide at least the subtitle and action for a app clip default experience") if subtitle_localized.nil? || action.nil?

      app = Deliver.cache[:app]
      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])
      version = fetch_edit_app_store_version(app, platform)

      UI.important("Will begin uploading app clip default experience metadata for '#{version.version_string}' on App Store Connect")

      # TODO: support handling more than one app clip target per app
      app_clips = app.get_app_clips
      app_clip = app_clips.first
      UI.user_error!("A build with an app clip must be uploaded to App Store Connect before uploading the default experience metadata") if app_clip.nil?

      # see if there's an existing experience for this version
      existing_default_experience = version.app_clip_default_experience
      if existing_default_experience
        # update the existing default experience
        existing_default_experience.update(attributes: { action: action })
        UI.message("Updated app clip default experience")
      else
        # create a new default experience
        default_experience = Spaceship::ConnectAPI::AppClipDefaultExperience.create(app_clip_id: app_clip.id, app_store_version_id: version.id, attributes: { action: action })
        UI.important("Created default experience #{default_experience.id}")
      end

      # update the subtitle localizations
      upload_subtitle_localizations(app_clip_default_experience: existing_default_experience, subtitle_localizations: subtitle_localized)
    end

    # from upload_metadata.rb
    def fetch_edit_app_store_version(app, platform, wait_time: 10)
      retry_if_nil("Cannot find edit app store version", wait_time: wait_time) do
        app.get_edit_app_store_version(platform: platform, includes: 'appClipDefaultExperience')
      end
    end

    # from upload_metadata.rb
    def retry_if_nil(message, tries: 5, wait_time: 10)
      loop do
        tries -= 1

        value = yield
        return value if value

        UI.message("#{message}... Retrying after #{wait_time} seconds (remaining: #{tries})")
        sleep(wait_time)

        return nil if tries.zero?
      end
    end

    def upload_subtitle_localizations(app_clip_default_experience:, subtitle_localizations:)
      localized_subtitle_attributes_by_locale = {}
      subtitle_localizations.keys.each do |key|
        localized_subtitle_attributes_by_locale[key] = {}
        localized_subtitle_attributes_by_locale[key][:create_attributes] = { subtitle: subtitle_localizations[key], locale: key }
        localized_subtitle_attributes_by_locale[key][:update_attributes] = { subtitle: subtitle_localizations[key] }
      end

      # update the subtitle
      existing_localizations = Spaceship::ConnectAPI::AppClipDefaultExperience.get(app_clip_default_experience_id: app_clip_default_experience.id, includes: 'appClipDefaultExperienceLocalizations').app_clip_default_experience_localizations

      # from upload_metadata.rb
      app_info_worker = FastlaneCore::QueueWorker.new do |locale|
        UI.message("Uploading app clip default experience metadata to App Store Connect for localized subtitle '#{locale}'")

        # find an existing localization
        existing_localization = existing_localizations.find { |l| locale.to_s.eql?(l.locale) }

        if existing_localization
          # update existing
          attributes = localized_subtitle_attributes_by_locale[locale][:update_attributes]
          existing_localization.update(attributes: attributes)
          UI.verbose("[#{locale}] Updated existing to #{attributes}")
        else
          # create new
          attributes = localized_subtitle_attributes_by_locale[locale][:create_attributes]
          Spaceship::ConnectAPI::AppClipDefaultExperienceLocalizations.create(default_experience_id: app_clip_default_experience.id, attributes: attributes)
          UI.verbose("[#{locale}] Created new with #{attributes}")
        end
      end
      app_info_worker.batch_enqueue(localized_subtitle_attributes_by_locale.keys)
      app_info_worker.start
    end
  end
end
