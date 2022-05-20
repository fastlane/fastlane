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

      app = Deliver.cache[:app]
      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])
      version = fetch_edit_app_store_version(app, platform)

      UI.important("Will begin uploading app clip default experience metadata for '#{version.version_string}' on App Store Connect")

      # TODO: support handling more than one app clip target per app
      app_clips = app.get_app_clips
      app_clip = app_clips.first

      # Validate options
      subtitle_localized = options[:app_clip_default_experience_subtitle]
      action = options[:app_clip_default_experience_action]
      has_options_specified = !subtitle_localized.nil? or !action.nil?

      if app_clip.nil?
        UI.user_error!("A build with an app clip must be uploaded to App Store Connect before uploading the default experience metadata") if has_options_specified
        # Nothing to do if the app clip is nil and no app clip options specified
        return if app_clip.nil?
      end

      unless has_options_specified
        # Handle the default case where there is an app clip, but no options specified.
        return copy_live_version_app_clip_default_experience_metadata(app: app, platform: platform, edit_version: version, app_clip: app_clip)
      end

      UI.user_error!("You must provide at least the subtitle and action for a app clip default experience") if subtitle_localized.nil? || action.nil?

      # see if there's an existing experience for this version
      default_experience = version.app_clip_default_experience
      if default_experience
        # update the existing default experience
        default_experience.update(attributes: { action: action })
        UI.message("Updated app clip default experience")
      else
        # create a new default experience
        default_experience = Spaceship::ConnectAPI::AppClipDefaultExperience.create(app_clip_id: app_clip.id, app_store_version_id: version.id, attributes: { action: action })
        UI.important("Created default experience for version '#{version.version_string}'")
      end

      # update the subtitle localizations
      upload_subtitle_localizations(app_clip_default_experience: default_experience, subtitle_localizations: subtitle_localized)
    end

    # from upload_metadata.rb
    def fetch_edit_app_store_version(app, platform, wait_time: 10)
      retry_if_nil("Cannot find edit app store version", wait_time: wait_time) do
        app.get_edit_app_store_version(platform: platform, includes: 'appClipDefaultExperience')
      end
    end

    def fetch_live_app_store_version(app, platform, wait_time: 10)
      retry_if_nil("Cannot find live app store version", wait_time: wait_time) do
        app.get_live_app_store_version(platform: platform, includes: 'appClipDefaultExperience')
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

    # Handle the case where an app clip exists, but the user did not specify any app clip default
    # experience metadata options. We check if the current editable version already has the app clip
    # default experience metadata. If not, copy over the live version's app clip default
    # experience metadata. This mimics the default behavior of creating an App Store version from
    # the ASC UI.
    #
    # This function will also produce warnings, but not outright fail, when it finds missing app
    # clip metadata.
    #
    # As of 2022-05-18, App Store versions created by the ASC API do not "carry over" the live
    # version's app clip default experience metadata, so we handle this for the user by default.
    #
    def copy_live_version_app_clip_default_experience_metadata(app:, platform:, edit_version:, app_clip:)
      edit_version_default_experience = edit_version.app_clip_default_experience
      if !edit_version_default_experience
        live_version = fetch_live_app_info(app, platform)
        # no live version to carry over metadata from
        return if live_version.nil?

        live_version_default_experience = live_version.app_clip_default_experience
        # no live version default experience to carry over metadata from
        return if live_version_default_experience.nil?

        # create a default experience and use the live version default experience as a "template"
        Spaceship::ConnectAPI::AppClipDefaultExperience.create(app_clip_id: app_clip.id, app_store_version_id: edit_version.id, template_default_experience_id: live_version_default_experience.id)

        # TODO: if the above code using the "template" doesn't work, we can use the following to manually copy the values
        #
        # default_experience.update(attributes: { action: live_version_default_experience.action })
        # UI.message("Added app clip default experience action from live version #{live_version.version}")

        # # copy the live version localizations
        # live_version_localizations = Spaceship::ConnectAPI::AppClipDefaultExperience.get(app_clip_default_experience_id: live_version_default_experience.id, includes: 'appClipDefaultExperienceLocalizations').app_clip_default_experience_localizations

        # live_version_localizations.each do |live_localization|
        #   attributes = { subtitle: live_localization.subtitle, locale: live_localization.locale }
        #   Spaceship::ConnectAPI::AppClipDefaultExperienceLocalizations.create(default_experience_id: default_experience.id, attributes: attributes)
        # end
      else
        # if the edit version app clip default experience already exists, just check it's values
        UI.important("ASC requires the app clip default experience to contain a valid `action` value. To specify this value in fastlane use deliver's `app_clip_default_experience_action` option.") if edit_version_default_experience.action.nil?
      end
    end
  end
end
