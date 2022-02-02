require_relative 'module'

require 'fastlane_core/build_watcher'
require 'fastlane_core/ipa_file_analyser'
require 'fastlane_core/pkg_file_analyser'

module Deliver
  class SubmitForReview
    def submit!(options)
      app = Deliver.cache[:app]

      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])
      version = app.get_edit_app_store_version(platform: platform)

      unless version
        UI.user_error!("Cannot submit for review - could not find an editable version for '#{platform}'")
        return
      end

      build = select_build(options, app, version, platform)

      update_export_compliance(options, app, build)
      update_idfa(options, app, version)
      update_submission_information(options, app)

      create_review_submission(options, app, version, platform)
      UI.success("Successfully submitted the app for review!")
    end

    private

    def create_review_submission(options, app, version, platform)
      # Can't submit a review if there is already a review in progress
      if app.get_in_progress_review_submission(platform: platform)
        UI.user_error!("Cannot submit for review - A review submission is already in progress")
      end

      # There can only be one open submission per platform per app
      # There might be a submission already created so we need to check
      # 1. Create the submission if its not already created
      # 2. Error if submission already contains some items for review (because we don't know what they are)
      submission = app.get_ready_review_submission(platform: platform, includes: "items")
      if submission.nil?
        submission = app.create_review_submission(platform: platform)
      elsif !submission.items.empty?
        UI.user_error!("Cannot submit for review - A review submission already exists with items not managed by fastlane. Please cancel or remove items from submission for the App Store Connect website")
      end

      submission.add_app_store_version_to_review_items(app_store_version_id: version.id)
      submission.submit_for_review
    end

    def select_build(options, app, version, platform)
      if options[:build_number] && options[:build_number] != "latest"
        UI.message("Selecting existing build-number: #{options[:build_number]}")

        build = Spaceship::ConnectAPI::Build.all(
          app_id: app.id,
          version: options[:app_version],
          build_number: options[:build_number],
          platform: platform
        ).first

        unless build
          UI.user_error!("Build number: #{options[:build_number]} does not exist")
        end
      else
        UI.message("Selecting the latest build...")
        build = wait_for_build_processing_to_be_complete(app: app, platform: platform, options: options)
      end
      UI.message("Selecting build #{build.app_version} (#{build.version})...")

      version.select_build(build_id: build.id)

      UI.success("Successfully selected build")

      return build
    end

    def update_export_compliance(options, app, build)
      submission_information = options[:submission_information] || {}
      submission_information = submission_information.transform_keys(&:to_sym)

      uses_encryption = submission_information[:export_compliance_uses_encryption]

      if build.uses_non_exempt_encryption.nil?
        UI.verbose("Updating build for export compliance status of '#{uses_encryption}'")

        if uses_encryption.to_s.empty?
          message = [
            "Export compliance is required to submit",
            "Add information to the :submission_information option...",
            "  Docs: http://docs.fastlane.tools/actions/deliver/#compliance-and-idfa-settings",
            "  Example: submission_information: { export_compliance_uses_encryption: false }",
            "  Example CLI:",
            "    --submission_information \"{\\\"export_compliance_uses_encryption\\\": false}\"",
            "This can also be set in your Info.plist with key 'ITSAppUsesNonExemptEncryption'"
          ].join("\n")
          UI.user_error!(message)
        end

        build = build.update(attributes: {
          usesNonExemptEncryption: uses_encryption
        })

        UI.verbose("Successfully updated build for export compliance status of '#{build.uses_non_exempt_encryption}' on App Store Connect")
      end
    end

    def update_idfa(options, app, version)
      submission_information = options[:submission_information] || {}
      submission_information = submission_information.transform_keys(&:to_sym)

      uses_idfa = submission_information[:add_id_info_uses_idfa]

      idfa_declaration = begin
                           version.fetch_idfa_declaration
                         rescue
                           nil
                         end

      updated_idfa = false

      # Set IDFA on version
      unless uses_idfa.nil?
        UI.verbose("Updating app store version for IDFA status of '#{uses_idfa}'")
        version = version.update(attributes: {
          usesIdfa: uses_idfa
        })
        UI.verbose("Updated app store version for IDFA status of '#{version.uses_idfa}'")
        updated_idfa = true
      end

      # Error if uses_idfa not set
      if version.uses_idfa.nil?
        message = [
          "Use of Advertising Identifier (IDFA) is required to submit",
          "Add information to the :submission_information option...",
          "  Docs: http://docs.fastlane.tools/actions/deliver/#compliance-and-idfa-settings",
          "  Example: submission_information: { add_id_info_uses_idfa: false }",
          "  Example: submission_information: {",
          "    add_id_info_uses_idfa: true,",
          "    add_id_info_serves_ads: false,",
          "    add_id_info_tracks_install: true,",
          "    add_id_info_tracks_action: true,",
          "    add_id_info_limits_tracking: true",
          "  }",
          "  Example CLI:",
          "    --submission_information \"{\\\"add_id_info_uses_idfa\\\": false}\""
        ].join("\n")
        UI.user_error!(message)
      end

      # Create, update, or delete IDFA declaration
      if uses_idfa == false
        if idfa_declaration
          UI.verbose("Deleting IDFA declaration")
          idfa_declaration.delete!
          updated_idfa = true
          UI.verbose("Deleted IDFA declaration")
        end
      elsif uses_idfa == true
        attributes = {
          honorsLimitedAdTracking: !!submission_information[:add_id_info_limits_tracking],
          servesAds: !!submission_information[:add_id_info_serves_ads],
          attributesAppInstallationToPreviousAd: !!submission_information[:add_id_info_tracks_install],
          attributesActionWithPreviousAd: !!submission_information[:add_id_info_tracks_action]
        }

        if idfa_declaration
          UI.verbose("Updating IDFA declaration")
          idfa_declaration.update(attributes: attributes)
          UI.verbose("Updated IDFA declaration")
        else
          UI.verbose("Creating IDFA declaration")
          version.create_idfa_declaration(attributes: attributes)
          UI.verbose("Created IDFA declaration")
        end

        updated_idfa = true
      end

      UI.success("Successfully updated IDFA declarations on App Store Connect") if updated_idfa
    end

    def update_submission_information(options, app)
      submission_information = options[:submission_information] || {}
      submission_information = submission_information.transform_keys(&:to_sym)

      content_rights = submission_information[:content_rights_contains_third_party_content]

      unless content_rights.nil?
        value = if content_rights
                  Spaceship::ConnectAPI::App::ContentRightsDeclaration::USES_THIRD_PARTY_CONTENT
                else
                  Spaceship::ConnectAPI::App::ContentRightsDeclaration::DOES_NOT_USE_THIRD_PARTY_CONTENT
                end

        UI.verbose("Updating contents rights declaration on App Store Connect")
        app.update(attributes: {
          contentRightsDeclaration: value
        })
        UI.success("Successfully updated contents rights declaration on App Store Connect")
      end
    end

    def wait_for_build_processing_to_be_complete(app: nil, platform: nil, options: nil)
      app_version = options[:app_version]

      app_version ||= FastlaneCore::IpaFileAnalyser.fetch_app_version(options[:ipa]) if options[:ipa]
      app_version ||= FastlaneCore::PkgFileAnalyser.fetch_app_version(options[:pkg]) if options[:pkg]

      app_build ||= FastlaneCore::IpaFileAnalyser.fetch_app_build(options[:ipa]) if options[:ipa]
      app_build ||= FastlaneCore::PkgFileAnalyser.fetch_app_build(options[:pkg]) if options[:pkg]

      latest_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(
        app_id: app.id,
        platform: platform,
        app_version: app_version,
        build_version: app_build,
        poll_interval: 15,
        return_when_build_appears: false,
        return_spaceship_testflight_build: false,
        select_latest: true
      )

      if !app_version.nil? && !app_build.nil?
        unless latest_build.app_version == app_version && latest_build.version == app_build
          UI.important("Uploaded app #{app_version} - #{app_build}, but received build #{latest_build.app_version} - #{latest_build.version}.")
        end
      end

      return latest_build
    end
  end
end
