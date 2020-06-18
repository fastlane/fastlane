require_relative 'module'

module Deliver
  class SubmitForReview
    def submit!(options)
      legacy_app = options[:app]
      app_id = legacy_app.apple_id
      app = Spaceship::ConnectAPI::App.get(app_id: app_id)

      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])
      version = app.get_edit_app_store_version(platform: platform)

      unless version
        UI.user_error!("Cannot submit for review - could not find an editable version for '#{platform}'")
        return
      end

      select_build(options, app, version, platform)

      # TODO: Do IDFA things (on idfa model)
      update_idfa(options, app, version)
      update_submission_information(options, app)

      # TODO: export compliance still uses legacy iTC API

      version.create_app_store_version_submission

      UI.success("Successfully submitted the app for review!")
    end

    private def select_build(options, app, version, platform)
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
    end

    def update_idfa(options, app, version)
      
    end

    def update_submission_information(options, app)
      # TODO: Still missing :content_rights_has_rights if that is still a thing
      submission_information = options[:submission_information] || {}
      if submission_information.include?(:content_rights_contains_third_party_content)
        value = if submission_information[:content_rights_contains_third_party_content]
          Spaceship::ConnectAPI::App::ContentRightsDeclaration::USES_THIRD_PARTY_CONTENT
        else
          Spaceship::ConnectAPI::App::ContentRightsDeclaration::DOES_NOT_USE_THIRD_PARTY_CONTENT
        end

        UI.success("Updating contents rights declaration on App Store Connect")
        app.update(attributes: {
          contentRightsDeclaration: value
        })
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
        return_spaceship_testflight_build: false
      )

      unless latest_build.app_version == app_version && latest_build.version == app_build
        UI.important("Uploaded app #{app_version} - #{app_build}, but received build #{latest_build.app_version} - #{latest_build.version}.")
      end

      return latest_build
    end
  end
end
